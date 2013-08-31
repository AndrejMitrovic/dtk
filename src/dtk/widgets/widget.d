/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.widget;

import core.thread;

import std.algorithm;
import std.exception;
import std.range;
import std.stdio;
import std.string;
import std.traits;
import std.conv;

import std.c.stdlib;

alias splitter = std.algorithm.splitter;

import dtk.app;
import dtk.event;
import dtk.geometry;
import dtk.interpreter;
import dtk.signals;
import dtk.types;
import dtk.utils;

import dtk.widgets.entry;
import dtk.widgets.options;
import dtk.widgets.scrollbar;

// todo: add tagging for Widget types as well.

/** The main class of all Dtk widgets. */
abstract class Widget
{
    /**
        Intercept an event that is sinking towards a child widget,
        which has $(D this) widget as its direct or indirect parent.

        You can assign $(D true) to $(D event.handled) in the
        event handler if you want to stop the event from propagating
        further down to the target child.

        Only widgets which are direct or indirect parents of the target
        widget will have their $(D onSinkEvent) handler called.

        This event handler is typically used in two cases:

        $(LI
            When an indirect parent of a widget may not hold a
            direct reference to the child widget, but would
            still want to intercept the event.
        )

        $(LI
            When a direct parent of a widget (or several widgets)
            wants to intercept the events that target the child widget.
        )

        E.g. observe this widget tree: Frame -> Notebook -> Button.

        The Frame might want to intercept the Button from being
        pressed, but it may not be aware of the Button's existence.
        The sinking phase of the event allows the parent widget (the Frame)
        to intercept the event and either modify it or block it from
        reaching any other children (Notebook) and the target widget
        itself (Button).

        Note: To intercept an event of an arbitrary widget, add your
        event handler to the target widget's $(D onEventFilter) list.
    */
    public EventHandler!Event onSinkEvent;

    /**
        Intercept an event that is bubbling toward the root parent.
        At this point the target child widget has already handled
        the event.

        You can assign $(D true) to $(D event.handled) in the
        event handler if you want to stop the event from propagating
        futher up the parent tree.

        Only widgets which are direct or indirect parents of the target
        widget will have their $(D onBubbleEvent) handler called.

        This event handler is typically used in two cases:

        $(LI
            When an indirect parent of a widget may not hold a
            direct reference to the child widget, but would
            still want to be notified when the child widget
            has received and handled an event.
        )

        $(LI
            When a direct parent of a widget (or several widgets)
            wants to be notified when a child widget has
            received and handled an event.
        )

        Note: To receive notification that an event was received and
        handled in an arbitrary widget, add your event handler to the
        target widget's $(D onEventNotify) list.
    */
    public EventHandler!Event onBubbleEvent;

    /**
        Handle an event for which the target is this widget.
        This generic event handler is invoked before an
        event-specific handler such as $(D onMouseEvent) is called.

        Note that at this point click/push events may have already
        caused the widget to physically change appearance.

        You can assign $(D true) to $(D event.handled) in the
        event handler if you want to stop the event from propagating
        to event-specific event handlers.
    */
    public EventHandler!Event onEvent;

    /**
        A list of event handlers which will be called in sequence
        just before this widget's onEvent handler.

        You can assign $(D true) to $(D event.handled) in the
        event handler if you want to stop the event from reaching
        the target widget's $(D onEvent) handler.

        This will also stop other event filters in thist list
        from being called.

        This event handler list is used for intercepting an event
        from reaching $(D this) widget.
    */
    public EventHandlerList!Event onEventFilter;

    /**
        A list of event handlers which will be called in sequence
        just after this widget's onEvent handler.

        You can assign $(D true) to $(D event.handled) in the
        event handler if you want to stop the event from reaching
        other event handlers in this list.

        This event handler list is used for notifying event
        handlers when an event has been received and handled
        by $(D this) widget.
    */
    public EventHandlerList!Event onEventNotify;

    /**
        Handle mouse-specific events.
    */
    public EventHandler!MouseEvent onMouseEvent;

    /**
        Handle keyboard-specific events.
    */
    public EventHandler!KeyboardEvent onKeyboardEvent;

    /** Ctor for widgets which know their parent during construction. */
    this(Widget parent, TkType tkType)
    {
        this.initialize(parent, tkType);
    }

    /**
        Delayed initialization. Some widgets in Tk must be parented (e.g. menus),
        but only receive their parent information once they're assigned to another
        widget (e.g. when a menubar is assigned to a window, or submenu to a menu).

        Once the parent is set the child should call the initialize method.
    */
    this(InitLater)
    {
    }

    /**
        Fake widgets which have event handlers but no actual Tk path name.
        Since each event handler uses a name mapping, this object must
        have a valid _name field.

        E.g. a widget such as a check menu is implicitly created through a
        parent menu object and doesn't have a widget path.
    */
    this(CreateFakeWidget)
    {
        string name = format("%s%s%s", _fakeWidgetPrefix, _threadID, _lastWidgetID++);
        this.initialize(name);
    }

    /**
        Ctor for widgets which are implicitly created by Tk,
        such as the toplevel "." window.
    */
    this(CreateToplevel)
    {
        this.initialize(".");
        this.bindTags(TkClass.toplevel);
    }

    /**
        Bind the DTK interceptor as the first event handler for this widget.

        By default a Tk widget has the tag bindings in this order:
        { widgetPath, widetClass, widgetToplevel, all }

        For our event mechanism we need to intercept the event before it reaches
        any other tag binding, and we have to remove the widgetToplevel from the
        tags list since our event dispatch mechanism will already notify the
        toplevel window of a widget when an event occurs.
    */
    private void bindTags(TkClass tkClass)
    {
        enforce(!_name.empty);
        tclEvalFmt("bindtags %s [list %s %s %s all ]", _name, _dtkInterceptTag, cast(string)tkClass, _name);
    }

    /** Factored out for delayed initialization. */
    package void initialize(Widget parent, TkType tkType)
    {
        enforce(parent !is null, "Parent cannot be null");

        /**
            If parent is the root window '.', '.widget' is the widget path.
            If parent is '.frame', '.frame.widget' is the widget path (dot added before widget).
        */
        string prefix;
        if (parent._name != ".")
            prefix = parent._name;

        string name = format("%s.%s%s%s", prefix, tkType.toString(), _threadID, _lastWidgetID++);
        tclEvalFmt("%s %s", tkType.toBaseType(), name);

        this.initialize(name);

        this.bindTags(tkType.toTkClass());

        //~ bindtags .button [list $buttonClass InterceptEvent .button all ]
    }

    /** Init the name. */
    private void initialize(string name)
    {
        enforce(!name.empty);
        _name = name;
        _widgetPathMap[_name] = this;
        _isInitialized = true;
    }

    /**
        Signal emitted for various widget events.

        $(RED Behavior note:) If the mouse cursor leaves the button area
        too quickly, and at the same time leaves the window area, the
        signal may be emitted with a delay of several ~100 milliseconds.
        To make sure the signal is emmitted as soon as the cursor leaves
        the button area, ensure that the button does not lay directly on
        an edge of a window (e.g. add some padding space to the button).

        Example:

        ----
        auto button = new Button(...);
        button.onEvent.connect((Widget w, Event e) {  }
        ----
    */
    //~ public Signal!(Widget, Event) onEvent;

    /** Commands: */

    // todo: this should be moved to a layout module
    public final void pack()
    {
        tclEvalFmt("pack %s", _name);
    }

    /// Note: The text property is implemented only in specific subclasses.
    @disable public string text;

    /// Note: The textWidth property is implemented only in specific subclasses.
    @disable public string textWidth;

    /** Widget states: */

    /**
        Check whether this widget is active.
        The mouse cursor is over the widget and pressing a
        mouse button will cause some action to occur.
        (aka "prelight" (Gnome), "hot" (Windows), "hover").
    */
    public final @property bool isActive()
    {
        return this.checkState("active");
    }

    /** Check whether this widget is enabled. */
    public final @property bool isEnabled()
    {
        return !this.isDisabled();
    }

    /** Enable this widget. */
    public final void enable()
    {
        this.setState("!disabled");
    }

    /** Check whether this widget is disabled. */
    public final @property bool isDisabled()
    {
        return this.checkState("disabled");
    }

    /** Disable this widget. */
    public final void disable()
    {
        this.setState("disabled");
    }

    /** Check whether this widget has keyboard focus. */
    public final @property bool isFocused()
    {
        return this.checkState("focus");
    }

    /**
        Make this widget have the keyboard focus.

        Todo note: this could be used to iterate
        automatically through a set of widgets,
        e.g. on key Release we set focus to another
        widget.
    */
    public final void focus()
    {
        tclEvalFmt("focus %s", _name);
    }

    /** Check whether this widget is being pressed. */
    public final @property bool isPressed()
    {
        return this.checkState("pressed");
    }

    /** Check whether this widget is selected. */
    public final @property bool isSelected()
    {
        return this.checkState("selected");
    }

    /** Check whether this widget is a foreground widget. */
    public final @property bool isInForeground()
    {
        return !this.isInBackground;
    }

    /**
        Check whether this widget is a background widget.
        Windows and the Mac have a notion of an "active" or
        foreground window. The background state is set for
        widgets in a background window, and cleared for those
        in the foreground window.
    */
    public final @property bool isInBackground()
    {
        return this.checkState("background");
    }

    /** Check whether this widget does not allow user modification. */
    public final @property bool isReadOnly()
    {
        return this.checkState("readonly");
    }

    /**
        Check whether this widget is in an alternate state.
        For example, used for checkbuttons and radiobuttons in
        the "tristate" or "mixed" state, and for buttons with "-default" active.
    */
    public final @property bool isAlternate()
    {
        return this.checkState("alternate");
    }

    /** ditto */
    public final @property bool isValid()
    {
        return !this.isInvalid;
    }

    /**
        The widget's value is invalid.
        Potential uses: scale widget value out of bounds,
        entry widget value failed validation.
    */
    public final @property bool isInvalid()
    {
        return this.checkState("invalid");
    }

    /**
        The mouse cursor is within the widget. This is similar to
        the active state; it is used in some themes for widgets that
        provide distinct visual feedback for the active widget in
        addition to the active element within the widget.
    */
    public final @property bool isHovered()
    {
        return this.checkState("hover");
    }

    /** End widget styles. */

    /** Destroy this widget. */
    public void destroy()
    {
        tclEvalFmt("destroy %s", _name);
        _isDestroyed = true;
    }

    /** Get the underlying Tcl widget name. Used for debugging and eval calls. */
    public string getTclName()
    {
        return _name;
    }

    /** Return the parent widget of this widget, or $(D null) if this widget is the main window. */
    @property Widget parentWidget()
    {
        string widgetPath = tclEvalFmt("winfo parent %s", _name);
        return cast(Widget)Widget.lookupWidgetPath(widgetPath);
    }

package:

    /* Set a scrollbar for this widget. */
    final void setScrollbar(Scrollbar scrollbar)
    {
        assert(!scrollbar._name.empty);
        string scrollCommand = format("%sscrollcommand", (scrollbar.orientation == Orientation.horizontal) ? "h" : "y");
        this.setOption(scrollCommand, format("%s set", scrollbar._name));

        string viewTarget = (scrollbar.orientation == Orientation.horizontal) ? "hview" : "yview";
        scrollbar.setOption("command", format("%s %s", this._name, viewTarget));
    }

    final bool checkState(string state)
    {
        return cast(bool)to!int(tclEvalFmt("%s instate %s", _name, state));
    }

    final void setState(string state)
    {
        tclEvalFmt("%s state %s", _name, state);
    }

    final T getOption(T)(string option)
    {
        return to!T(tclEvalFmt("%s cget -%s", _name, option));
    }

    final string setOption(T)(string option, T value)
    {
        return tclEvalFmt(`%s configure -%s %s`, _name, option, value._tclEscape);
    }

    /**
        Create a Tcl variable.

        The function returns the variable name.
    */
    static string makeVar()
    {
        string varName = getUniqueVarName();
        tclMakeVar(varName);
        return varName;
    }

    /**
        Create a traced Tcl variable, which will invoke the
        dtk callback and pass event type and the variable value
        whenever the variable is changed.

        The function returns the variable name.
    */
    static string makeTracedVar(TkEventType eventType)
    {
        string varName = getUniqueVarName();
        tclMakeTracedVar(varName, eventType.text, _dtkCallbackIdent);
        return varName;
    }

    /** Create a unique new callback name. */
    static string createCallbackName()
    {
        int newSlotID = _lastCallbackID++;
        return format("%s%s_%s", _callbackPrefix, _threadID, newSlotID).replace(":", "_");
    }

    /* API: Initialize the global dtk callback and the dtk interceptor tag bindings. */
    public static void initClass()
    {
        _initDtkCallback();
        _initDtkInterceptor();
    }

    /// ditto
    private static void _initDtkCallback()
    {
        enforce(!_dtkCallbackInitialized, "dtk callback already initialized.");

        Tcl_CreateObjCommand(tclInterp,
                             cast(char*)_dtkCallbackIdent.toStringz,
                             &dtkCallbackHandler,
                             null,  // no extra client data
                             &dtkCallbackDeleter);

        _dtkCallbackInitialized = true;
    }

    // all the event arguments captures by the bind command (todo: %W should be caught)
    enum string eventArgs = "%W %w %x %y %k %K %h %X %Y";
    //~ tclEvalFmt("bind %s <Enter> { %s %s %s }", _dtkInterceptTag, _dtkCallbackIdent, EventType.Enter, eventArgs);


    // validation arguments captured by validatecommand
    enum string validationArgs = "%d %i %P %s %S %v %V %W";

    static immutable mouseEventArgs = [TkSubs.detail, tkSubs.window_id].join(" ");

    /// ditto
    private static void _initDtkInterceptor()
    {
        //~ tclEvalFmt("bind %s <KeyPress> { %s %s %s }", _dtkInterceptTag, _dtkCallbackIdent, EventType.keyboard, eventArgs);

        // #1 == _dtkCallbackIdent
        // #2 == EventType.mouse
        // #3+ == eventArgs



        tclEvalFmt("bind %s <Button-1> { %s %s %s }", _dtkInterceptTag, _dtkCallbackIdent, EventType.mouse, mouseEventArgs);

        //~ enum string tcl_flags = "%W";
        //~ tclEvalFmt(`bind %s <Button-1> "%s %s"`, _dtkInterceptTag, _dtkCallbackIdent, tcl_flags);

    }

    static auto safeToInt(T)(T* val)
    {
        auto res = to!string(val);
        if (res == "??")  // note: edge-case, but there might be more of them
            return 0;    // note2: "0" is just a guess, not sure what else to set it to.

        return to!int(res);
    }

    static extern(C)
    int dtkCallbackHandler(ClientData clientData, Tcl_Interp* interp, int objc, const Tcl_Obj** objv)
    {
        // todo:
        //~ TCL_BREAK;
        //~ TCL_CONTINUE;

        if (objc < 2)  // DTK event signals need at least 2 arguments
            return TCL_OK;

        EventType type = to!EventType(Tcl_GetString(objv[1]).
        switch (


        //~ event.x       = safeToInt(Tcl_GetString(objv[1]));
        //~ event.y       = safeToInt(Tcl_GetString(objv[2]));
        //~ event.keycode = safeToInt(Tcl_GetString(objv[3]));
        //~ event.width   = safeToInt(Tcl_GetString(objv[4]));
        //~ event.height  = safeToInt(Tcl_GetString(objv[5]));
        //~ event.width   = safeToInt(Tcl_GetString(objv[6]));
        //~ event.height  = safeToInt(Tcl_GetString(objv[7]));


        import std.stdio;

        string getString(size_t index)
        {
            return to!string(Tcl_GetString(objv[index]));
        }

        void printString(size_t index)
        {
            stderr.writefln("-- received #%s: %s", index + 1, getString(index));
        }

        foreach (i; 0 .. objc)
        {
            printString(i);
        }

        return TCL_BREAK;

        // todo: use try/catch on a Throwable, we don't want to escape exceptions to the C side.
        // todo: extract the types, and the event type, and the direct it to a D function that can

       /+  int slotID = cast(int)clientData;

        if (auto callback = slotID in _callbackMap)
        {
            Event event;  // todo: update

            if (objc > 1)  // todo: objc is the objv count, not sure if we should always assign all fields
            {
                try
                {
                    event.type = tclConv!TkEventType(Tcl_GetString(objv[1]));
                }
                catch (ConvException ce)
                {
                    stderr.writefln("Couldn't convert: `%s`", to!string(Tcl_GetString(objv[1])));
                    throw ce;
                }

                switch (event.type) with (TkEventType)
                {
                    case TkCheckButtonToggle:
                    case TkRadioButtonSelect:
                    case TkComboboxChange:
                    case TkTextChange:
                    case TkListboxChange:
                    case TkProgressbarChange:
                    case TkScaleChange:
                    case TkSpinboxChange:
                    case TkCheckMenuItemToggle:
                    case TkRadioMenuSelect:
                    {
                        event.state = to!string(Tcl_GetString(objv[2]));
                        break;
                    }

                    case TkValidate:
                    case TkFailedValidation:
                    {
                        string validEventArgs = to!string(Tcl_GetString(objv[2]));

                        auto args = validEventArgs.splitter(" ");

                        event.validateEvent.type = toValidationType(to!int(args.front));
                        args.popFront();

                        event.validateEvent.charIndex = to!sizediff_t(args.front);
                        args.popFront();

                        event.validateEvent.newValue = args.front == "{}" ? null : args.front;
                        args.popFront();

                        event.validateEvent.curValue = args.front == "{}" ? null : args.front;
                        args.popFront();

                        event.validateEvent.changeValue = args.front == "{}" ? null : args.front;
                        args.popFront();

                        event.validateEvent.validationMode = toValidationMode(args.front);
                        args.popFront();

                        event.validateEvent.validationCondition = toValidationMode(args.front);
                        args.popFront();
                        break;
                    }

                    default:
                    {
                        foreach (idx, field; event.tupleof)
                        static if (idx != 0)  // first element is the callback name
                        {
                            if (objc > idx)
                            {
                                //~ stderr.writefln("arg %s: %s", idx, to!string(Tcl_GetString(objv[idx])));
                                event.tupleof[idx - 1] = tclConv!(typeof(event.tupleof[idx - 1]))(Tcl_GetString(objv[idx]));
                            }
                        }
                    }
                }
            }

            //~ stderr.writefln("emitting: %s %s", callback.widget, event);
            callback.signal.emit(callback.widget, event);
            return TCL_OK;
        }
        else
        {
            Tcl_SetResult(interp, cast(char*)"Trying to invoke non-existent callback", TCL_STATIC);
            return TCL_ERROR;
        } +/

        //~ return TCL_OK;
    }

    // no-op
    static extern(C)
    void dtkCallbackDeleter(ClientData clientData) { }

    /** Create a unique Tcl variable name. */
    static string getUniqueVarName()
    {
        int newSlotID = _lastVariableID++;
        return format("%s%s_%s", _variablePrefix, _threadID, newSlotID);
    }

    /**
        Find the binding of a Tcl widget path and return the
        mapped widget or null if there is no such path mapping.
    */
    static Widget lookupWidgetPath(string path)
    {
        if (auto widget = path in _widgetPathMap)
            return *widget;

        return null;
    }

package:

    /** The Tcl identifier for the D event callback. */
    enum _dtkCallbackIdent = "dtk::callback_handler";

    /** Is the Tcl callback registered. */
    __gshared bool _dtkCallbackInitialized;

    /** Used for Tcl bindtags. */
    enum _dtkInterceptTag = "dtk::intercept_tag";

    // invoked per-thread: store a unique thread identifier
    static this()
    {
        _threadID = cast(size_t)cast(void*)Thread.getThis;
    }

    /** Unique Thread ID. Needed to create thread-global unique identifiers for Tcl/Tk. */
    static size_t _threadID;

    /** This widget's unique name. */
    public string _name;

    /** Counter to create a thread-global unique widget name (_threadID is used in mangling). */
    static int _lastWidgetID = 0;

    /** Counter to create a unique thread-local callback ID. */
    static int _lastCallbackID;

    enum _fakeWidgetPrefix = "dtk_fake_widget";

    /** Prefix for callbacks to avoid name clashes. */
    enum _callbackPrefix = "dtk::call";

    /** Counter to create a unique thread-local variable ID. */
    static int _lastVariableID;

    /** Prefix for variables to avoid name clashes. */
    enum _variablePrefix = "::dtk_var";

    /** Mapping of Tcl widget paths to Widget objects. */
    static Widget[string] _widgetPathMap;

    /**
        Set when the widget has been initialized. Some delayed-initialized widgets
        can be initialized after construction when initialize is called.
    */
    bool _isInitialized;

    /**
        Set when the widget is destroyed. This either happens when the destroy()
        method is called or when a parent widget which manages the lifetime of
        the child destroys the child (e.g. $(D tree.destroy(subTree))).
    */
    bool _isDestroyed;
}

/// Tk and Ttk widget types
package enum TkType : string
{
    button      = "ttk::button",
    checkbutton = "ttk::checkbutton",
    combobox    = "ttk::combobox",
    entry       = "ttk::entry",
    frame       = "ttk::frame",
    label       = "ttk::label",
    labelframe  = "ttk::labelframe",
    listbox     = "tk::listbox",     // note: no ttk::listbox yet in v8.6
    menu        = "menu",            // note: no ttk::menu
    notebook    = "ttk::notebook",
    panedwindow = "ttk::panedwindow",
    progressbar = "ttk::progressbar",
    radiobutton = "ttk::radiobutton",
    scale       = "ttk::scale",
    separator   = "ttk::separator",
    sizegrip    = "ttk::sizegrip",
    scrollbar   = "ttk::scrollbar",
    spinbox     = "ttk::spinbox",
    text        = "tk::text",        // note: no ttk::text
    toplevel    = "tk::toplevel",    // note: no ttk::toplevel
    tree        = "ttk::treeview",
}

///
package string toString(TkType tkType)
{
    // note: cannot use :: in name because it can sometimes be
    // interpreted in a special way, e.g. tk hardcodes some
    // methods to ttk::type.func.name
    return tkType.replace(":", "_");
}

/// Tk class types for each widget type
package enum TkClass : string
{
    button      = "TButton",
    checkbutton = "TCheckbutton",
    combobox    = "TCombobox",
    entry       = "TEntry",
    frame       = "TFrame",
    label       = "TLabel",
    labelframe  = "TLabelframe",
    listbox     = "Listbox",
    menu        = "Menu",
    notebook    = "TNotebook",
    panedwindow = "TPanedwindow",
    progressbar = "TProgressbar",
    radiobutton = "TRadiobutton",
    scale       = "TScale",
    separator   = "TSeparator",
    sizegrip    = "TSizegrip",
    scrollbar   = "TScrollbar",
    spinbox     = "TSpinbox",
    text        = "Text",
    toplevel    = "Toplevel",
    tree        = "Treeview",
}

///
package TkClass toTkClass(TkType tkType)
{
    // note: safe since to!string will return the member name, not the string value
    return to!TkClass(to!string(tkType));
}

///
package enum TkSubs : string
{
    client_request = "%#",
    win_below_target = "%a",
    mouse_button = "%b",
    count = "%c",
    detail = "%d",
    focus = "%f",
    height = "%h",
    win_hex_id = "%i",
    keycode = "%k",
    mode = "%m",
    override_redirect = "%o",
    place = "%p",
    state = "%s",
    timestamp = "%t",
    width = "%w",
    x_pos = "%x",
    y_pos = "%y",
    uni_char = "%A",
    border_width = "%B",
    mouse_wheel_delta = "%D",
    send_event_type = "%E",
    keysym_text = "%K",
    keysym_decimal = "%N",
    property_name = "%P",
    root_window_id = "%R",
    subwindow_id = "%S",
    type = "%T",
    window_id = "%W",
    x_root = "%X",
    y_root = "%Y",
}

// mapping of DTK event types to the subs we need for the bindings
//~ package TkSubs[][EventType] eventTypeSubs;

package struct InitLater { }
package struct CreateFakeWidget { }
package struct CreateToplevel { }
