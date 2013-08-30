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
import dtk.options;
import dtk.signals;
import dtk.types;
import dtk.utils;

import dtk.widgets.entry;
import dtk.widgets.scrollbar;

/**
    Specifies how to display the image relative to the text,
    in the case both text and an image are present in a widget.
*/
enum Compound
{
    none,   /// Display the image if present, otherwise the text.
    text,   /// Display text only.
    image,  /// Display the image only.
    center, /// Display the text centered on top of the image.
    top,    /// Display the text above of the text.
    bottom, /// Display the text below of the text.
    left,   /// Display the text to the left of the text.
    right,  /// Display the text to the right of the text.
}

/**
    Specifies the type of selection mode a widget has.
*/
enum SelectMode
{
    single,        /// Allow only a single selection.
    multiple,      /// Allow multiple selections.
    old_single,    /// deprecated
    old_multiple,  /// deprecated
}

package SelectMode toSelectMode(string input)
{
    switch (input) with (SelectMode)
    {
        case "browse":     return single;
        case "extended":   return multiple;
        case "single":     return old_single;
        case "multiple":   return old_multiple;
        default:           assert(0, format("Unhandled select input: '%s'", input));
    }
}

package string toString(SelectMode selectMode)
{
    final switch (selectMode) with (SelectMode)
    {
        case single:        return "browse";
        case multiple:      return "extended";
        case old_single:    return "single";
        case old_multiple:  return "multiple";
    }
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

package struct InitLater { }
package struct CreateFakeWidget { }

/** The main class of all Dtk widgets. */
abstract class Widget
{
    /**
        Intercept an event that is sinking towards a child widget.
        You can assign $(D true) to $(D event.handled) in the
        event handler if you want to stop the event from propagating
        further down to the target child.
    */
    public EventHandler!Event onPreEvent;

    /**
        Intercept an event that is bubbling toward the root parent.
        At this point the target child widget has already handled
        the event.

        You can assign $(D true) to $(D event.handled) in the
        event handler if you want to stop the event from propagating
        futher up the parent tree.
    */
    public EventHandler!Event onPostEvent;

    /**
        Handle an event meant for this widget. This generic event
        handler is invoked before an event-specific handler
        such as onMouseEvent is called.

        Note that at this point click/push events may have already
        caused the widget to physically change appearance.

        You can assign $(D true) to $(D event.handled) in the
        event handler if you want to stop the event from propagating
        to event-specific event handlers;
    */
    public EventHandler!Event onEvent;

    /**
        Handle mouse-specific events.
    */
    public EventHandler!MouseEvent onMouseEvent;

    /**
        Handle keyboard-specific events.
    */
    public EventHandler!KeyboardEvent onKeyboardEvent;

    /**
        Delayed initialization. Some widgets in Tk must be parented (e.g. menus),
        but only receive their parent information once they're assigned to another
        widget (e.g. when a menubar is assigned to a window, or submenu to a menu).

        Once the parent is set they should call the initialize method.
    */
    this(InitLater) { }

    /**
        Fake widgets which have event handlers but no actual Tk path name.
        Since each event handler uses a name mapping, this object must
        have a valid _name field.

        E.g. a widget such as a check menu is implicitly created through a
        parent menu object and doesn't have a widget path.
    */
    this(CreateFakeWidget createFakeWidget)
    {
        this.initialize(createFakeWidget);
    }

    // ditto
    package void initialize(CreateFakeWidget)
    {
        string name = format("%s%s%s", _fakeWidgetPrefix, _threadID, _lastWidgetID++);
        this.initialize(name, EmitGenericSignals.no);
    }

    /**
        Ctor for widgets which are implicitly created by Tk,
        such as the toplevel "." window.
    */
    package this(string name, EmitGenericSignals emitGenericSignals)
    {
        this.initialize(name, emitGenericSignals);
    }

    /** Required to be a method instead of a ctor to allow delayed initialization. */
    package void initialize(string name, EmitGenericSignals emitGenericSignals)
    {
        enforce(!name.empty);
        _name = name;
        _widgetPathMap[_name] = this;

        // todo: it's unnecessary to make so many callbacks, we only need one per class, and
        // we can use %W to get the widget path, which is valid for all Tk event types.
        _eventCallbackIdent = this.createCallback(&onEvent);

        if (emitGenericSignals == EmitGenericSignals.yes)
        {
            // todo now: instead of binding each widget with this same code, we should bind the class type,
            // maybe in the app class or in a shared this ctor.
            this.evalFmt("bind %s <Enter> { %s %s %s }", _name, _eventCallbackIdent, EventType.Enter, eventArgs);
            this.evalFmt("bind %s <Leave> { %s %s %s }", _name, _eventCallbackIdent, EventType.Leave, eventArgs);
        }

        _isInitialized = true;
    }

    this(Widget parent, TkType tkType, DtkOptions opt, EmitGenericSignals emitGenericSignals = EmitGenericSignals.yes)
    {
        this.initialize(parent, tkType, emitGenericSignals, opt.options2string);
    }

    this(Widget parent, TkType tkType, EmitGenericSignals emitGenericSignals = EmitGenericSignals.yes, string opts = "")
    {
        this.initialize(parent, tkType, emitGenericSignals, opts);
    }

    package void initialize(Widget parent, TkType tkType, DtkOptions opt, EmitGenericSignals emitGenericSignals = EmitGenericSignals.yes)
    {
        this.initialize(parent, tkType, emitGenericSignals, opt.options2string);
    }

    package void initialize(Widget parent, TkType tkType, EmitGenericSignals emitGenericSignals = EmitGenericSignals.yes, string opts = "")
    {
        string prefix;  // '.' is the root window
        if (parent !is null && parent._name != ".")
            prefix = parent._name;

        string name = format("%s.%s%s%s", prefix, tkType.toString(), _threadID, _lastWidgetID++);
        this.evalFmt("%s %s %s", tkType.toBaseType(), name, opts);

        this.initialize(name, emitGenericSignals);
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
        evalFmt("pack %s", _name);
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
        evalFmt("focus %s", _name);
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
        this.evalFmt("destroy %s", _name);
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
        string widgetPath = evalFmt("winfo parent %s", _name);
        return cast(Widget)Widget.lookupWidgetPath(widgetPath);
    }

package:

    /* Set a scrollbar for this widget. */
    package void setScrollbar(Scrollbar scrollbar)
    {
        assert(!scrollbar._name.empty);
        string scrollCommand = format("%sscrollcommand", (scrollbar.orientation == Orientation.horizontal) ? "h" : "y");
        this.setOption(scrollCommand, format("%s set", scrollbar._name));

        string viewTarget = (scrollbar.orientation == Orientation.horizontal) ? "hview" : "yview";
        scrollbar.setOption("command", format("%s %s", this._name, viewTarget));
    }

    final string evalFmt(T...)(string fmt, T args)
    {
        return App.evalFmt(fmt, args);
    }

    final string eval(string cmd)
    {
        return App.eval(cmd);
    }

    final bool checkState(string state)
    {
        return cast(bool)to!int(evalFmt("%s instate %s", _name, state));
    }

    final void setState(string state)
    {
        evalFmt("%s state %s", _name, state);
    }

    final T getOption(T)(string option)
    {
        return to!T(evalFmt("%s cget -%s", _name, option));
    }

    final string setOption(T)(string option, T value)
    {
        return evalFmt(`%s configure -%s %s`, _name, option, value._tclEscape);
    }

    final T getVar(T)(string varName)
    {
        // todo: use TCL_LEAVE_ERR_MSG
        // todo: check _interp error
        // tood: check all interpreter error codes

        enum getFlags = 0;
        static if (isArray!T && !isSomeString!T)
        {
            Appender!T result;

            auto tclObj = Tcl_GetVar2Ex(App._interp, cast(char*)varName.toStringz, null, getFlags);
            enforce(tclObj !is null);

            int arrCount;
            Tcl_Obj **array;
            enforce(Tcl_ListObjGetElements(App._interp, tclObj, &arrCount, &array) != TCL_ERROR);

            foreach (index; 0 .. arrCount)
                result ~= to!string(Tcl_GetString(array[index]));

            return result.data;
        }
        else
        {
            version (DTK_LOG_EVAL)
                stderr.writefln("Tcl_GetVar(%s)", varName);

            return to!T(Tcl_GetVar(App._interp, cast(char*)varName.toStringz, getFlags));
        }
    }

    final void setVar(T)(string varName, T value)
    {
        static if (isArray!T && !isSomeString!T)
        {
            this.evalFmt("set %s [list %s]", varName, value.join(" "));
        }
        else
        {
            version (DTK_LOG_EVAL)
                stderr.writefln("Tcl_SetVar(%s, %s)", varName, to!string(value));

            enum setFlags = 0;
            Tcl_SetVar(App._interp, cast(char*)varName.toStringz, cast(char*)(to!string(value).toStringz), setFlags);
        }
    }

    /**
        Create a tracec Tcl variable, which will invoke the
        generic onEvent signal handler and pass the variable
        value and a special tag.

        The function returns the variable name.
    */
    final string createTracedTaggedVariable(EventType eventType)
    {
        assert(!_eventCallbackIdent.empty);

        string varName = this.createVariableName();
        string tracerFunc = format("tracer_%s", this.createCallbackName());

        // tracer used instead of -command
        this.evalFmt(
            `
            proc %s {varname args} {
                upvar #0 $varname var
                %s %s $var
            }
            `, tracerFunc, _eventCallbackIdent, eventType);

        // hook up the tracer for this unique variable
        this.evalFmt(`trace add variable %s write "%s %s"`, varName, tracerFunc, varName);

        return varName;
    }

    /** Create a unique new callback name. */
    static string createCallbackName()
    {
        int newSlotID = _lastCallbackID++;
        return format("%s%s_%s", _callbackPrefix, _threadID, newSlotID).replace(":", "_");
    }

    /** Create a Tcl callback. */
    final string createCallback(Signal!(Widget, Event)* signal)
    {
        int newSlotID = _lastCallbackID++;

        ClientData clientData = cast(ClientData)newSlotID;
        string callbackName = format("%s%s_%s", _callbackPrefix, _threadID, newSlotID);

        Tcl_CreateObjCommand(App._interp,
                             cast(char*)callbackName.toStringz,
                             &callbackHandler,
                             clientData,
                             &callbackDeleter);

        _callbackMap[newSlotID] = Callback(this, signal);
        return callbackName;
    }

    static extern(C)
    void callbackDeleter(ClientData clientData)
    {
        int slotID = cast(int)clientData;
        _callbackMap.remove(slotID);
    }

    static extern(C)
    int callbackHandler(ClientData clientData, Tcl_Interp* interp, int objc, const Tcl_Obj** objv)
    {
        int slotID = cast(int)clientData;

        if (auto callback = slotID in _callbackMap)
        {
            Event event;  // todo: update

            if (objc > 1)  // todo: objc is the objv count, not sure if we should always assign all fields
            {
                try
                {
                    event.type = tclConv!EventType(Tcl_GetString(objv[1]));
                }
                catch (ConvException ce)
                {
                    stderr.writefln("Couldn't convert: `%s`", to!string(Tcl_GetString(objv[1])));
                    throw ce;
                }

                switch (event.type) with (EventType)
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
        }
    }

    /** Create a Tcl variable name. */
    static string createVariableName()
    {
        int newSlotID = _lastVariableID++;
        return format("%s%s_%s", _variablePrefix, _threadID, newSlotID);
    }

    /** Create a Tcl variable. */
    static void createTclVariable(string varName)
    {
        App.evalFmt("set %s true", varName);
    }

    /**
        Find the binding of a Tcl widget path and return the mapped widget,
        or return null if there is no such path mapping.
    */
    static Widget lookupWidgetPath(string path)
    {
        if (auto widget = path in _widgetPathMap)
            return *widget;

        return null;
    }

package:

    /** The Tcl identifier for the onEvent signal callback. */
    string _eventCallbackIdent;

    // invoked per-thread: store a unique integral identifier
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

    static struct Callback
    {
        Widget widget;
        Signal!(Widget, Event)* signal;
    }

    /** All thread-local active callbacks. */
    static Callback[int] _callbackMap;

    /** All widget paths -> widget maps */
    static Widget[string] _widgetPathMap;

    /**
        Set when the widget has been initialized. Some delayed-initialized widgets
        can be initialized after construction until initialize is called.
    */
    bool _isInitialized;

    /**
        Set when the widget is destroyed. This either happens when the destroy()
        method is called, or when a parent widget which manages the lifetime of
        the object destroys the widget (e.g. $(D Tree.destroy(Tree tree))).
    */
    bool _isDestroyed;
}

// all the event arguments captures by the bind command
package immutable string eventArgs = "%x %y %k %K %w %h %X %Y";

// validation arguments captured by validatecommand
package immutable string validationArgs = "%d %i %P %s %S %v %V %W";

///
package string toString(TkType tkType)
{
    // note: cannot use :: in name because it can sometimes be
    // interpreted in a special way, e.g. tk hardcodes some
    // methods to ttk::type.func.name
    return tkType.replace(":", "_");
}

///
package template EnumBaseType(E) if (is(E == enum))
{
    static if (is(E B == enum))
        alias EnumBaseType = B;
}

/// required due to Issue 10814 - Formatting string-based enum prints its name instead of its value
package EnumBaseType!E toBaseType(E)(E val)
{
    return cast(typeof(return))val;
}
