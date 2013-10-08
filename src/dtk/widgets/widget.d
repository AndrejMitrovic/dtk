/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.widget;

debug = DTK_LOG_EVENTS;

import core.thread;

import std.algorithm;
import std.exception;
import std.range;
import std.stdio;
import std.traits;
import std.typecons;

import std.c.stdlib;

alias splitter = std.algorithm.splitter;

import dtk.app;
import dtk.dispatch;
import dtk.event;
import dtk.geometry;
import dtk.keymap;
import dtk.interpreter;
import dtk.signals;
import dtk.types;
import dtk.utils;

import dtk.platform;

import dtk.widgets.button;
import dtk.widgets.entry;
import dtk.widgets.options;
import dtk.widgets.scrollbar;
import dtk.widgets.window;

/** The main class of all Dtk widgets. */
abstract class Widget
{
    /**
        A list of event handlers which will be called in sequence
        before any other event handlers.

        You can assign $(D true) to $(D event.handled) in the
        event handler if you want to stop the event from going
        into the sinking phase. This will also stop other event
        filters in this list from being called.
    */
    public Signal!Event onFilterEvent;

    /**
        Intercept an event that is sinking towards a child widget,
        which has $(D this) widget as its direct or indirect parent.

        When to use:
        If a parent widget has many child widgets, either direct
        children on sub-children of the parent, and it wants to
        intercept events that target those children, you should use
        $(D onSinkEvent).

        This allows you to capture events without having to know
        in advance which widgets to track the events for.

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
        event handler to the target widget's $(D onFilterEvent) list.
    */
    public Signal!Event onSinkEvent;

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
    public Signal!Event onEvent;

    /**
        A list of event handlers which will be called in sequence
        after this widget's generic (onEvent) or specific
        (e.g. onKeyboardEvent) event handler.

        You can assign $(D true) to $(D event.handled) in the
        event handler if you want to stop the event from reaching
        other event handlers in this list. However this will not
        stop the event from reaching $(D onBubbleEvent) handlers.

        This event handler list is used for notifying event
        handlers when an event has been received and handled
        by $(D this) widget.
    */
    public Signal!Event onNotifyEvent;

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
        target widget's $(D onNotifyEvent) list.
    */
    public Signal!Event onBubbleEvent;

    /**
        Handle mouse-specific events.

        $(BLUE Behavior note:) If the mouse cursor leaves the button area
        too quickly, and at the same time leaves the window area, the
        signal may be emitted with a delay of several ~100 milliseconds.
        To make sure the signal is emmitted as soon as the cursor leaves
        the button area, ensure that the button does not lay directly on
        an edge of a window (e.g. add some padding space next to the button).
    */
    public Signal!MouseEvent onMouseEvent;

    /**
        Handle keyboard-specific events.
    */
    public Signal!KeyboardEvent onKeyboardEvent;

    /**
        Handle geometry events, such as when this widget's
        position, size, or border width changes.
    */
    public Signal!GeometryEvent onGeometryEvent;

    /**
        The mouse pointer entered or left this widget's area.
    */
    public Signal!HoverEvent onHoverEvent;

    /**
        The widget was either focused in or focused out.
    */
    public Signal!FocusEvent onFocusEvent;

    /**
        The widget is a source of a drag and drop event.
    */
    public Signal!DragEvent onDragEvent;

    /**
        The widget is a target of a drag and drop event.
    */
    public Signal!DropEvent onDropEvent;

    /**
        Handle the event when a widget is destroyed.

        $(B Note:) You cannot stop a widget from being destroyed,
        the destroy event is generated after the widget is destroyed.
    */
    public Signal!DestroyEvent onDestroyEvent;

    /** Ctor for widgets which know their parent during construction. */
    this(Widget parent, TkType tkType, WidgetType widgetType, string extraOpts = null)
    {
        this.widgetType = widgetType;
        this.initialize(parent, tkType, extraOpts);
    }

    /**
        Delayed initialization. Some widgets in Tk must be parented (e.g. menus),
        but only receive their parent information once they're assigned to another
        widget (e.g. when a menubar is assigned to a window, or submenu to a menu).

        Once the parent is set the child should call the initialize method.
    */
    this(InitLater, WidgetType widgetType)
    {
        this.widgetType = widgetType;
    }

    /**
        Fake widgets which have event handlers but no actual Tk path name.
        Since each event handler uses a name mapping, this object must
        have a valid _name field.

        E.g. a widget such as a check menu is implicitly created through a
        parent menu object and doesn't have a widget path.
    */
    this(CreateFakeWidget, WidgetType widgetType)
    {
        this.widgetType = widgetType;
        string name = format("%s%s", _fakeWidgetPrefix, _lastWidgetID++);
        this.initialize(name);
        _isFakeWidget = true;
    }

    /**
        Ctor for widgets which are implicitly created by Tk,
        such as the toplevel "." window.
    */
    this(CreateToplevel, WidgetType widgetType)
    {
        this.widgetType = widgetType;
        this.initialize(".");
        this.bindTags(TkClass.toplevel);
    }

    /**
        The built-in dynamic type of this object.
        Use this to when you want to avoid doing
        an expensive derived cast.

        Instead you can do a static cast based on
        this widgetType field.

        Example:
        -----
        // convenience template for static casting
        T StaticCast(T, S)(S source)
        {
            return cast(T)(*cast(void**)&source);
        }

        Widget widget = new Button(...);
        if (widget.widgetType == WidgetType.button)
        {
            // at this point it's safe to use a static cast
            Button button = StaticCast!Button(widget);
        }
        -----

        Tip: You can use the $(D toWidgetType) template
        to retrieve the mapping of a widget class
        to a widget type.

        -----
        if (widget.widgetType == toWidgetType!Button)
        {
            auto button = StaticCast!Button(widget);
        }
        -----
    */
    public const(WidgetType) widgetType;

    /**
        Get the current widget position, relative to its parent.
        The parent is either another window, or the desktop.
    */
    @property Point position()
    {
        string x = tclEvalFmt("winfo x %s", _name);
        string y = tclEvalFmt("winfo y %s", _name);
        return Point(to!int(x), to!int(y));
    }

    /**
        Get the current widget position, relative to the root window.
    */
    @property Point absPosition()
    {
        string x = tclEvalFmt("winfo rootx %s", _name);
        string y = tclEvalFmt("winfo rooty %s", _name);
        return Point(to!int(x), to!int(y));
    }

    /**
        Get the current widget size.
    */
    @property Size size()
    {
        string width = tclEvalFmt("winfo width %s", _name);
        string height = tclEvalFmt("winfo height %s", _name);
        return Size(to!int(width), to!int(height));
    }

    /** Get the current widget geometry. */
    @property Rect geometry()
    {
        return tclEvalFmt("wm geometry %s", _name).toGeometry();
    }

    /** Commands: */

    /// Note: These properties are implemented in specific subclasses.
    @disable public string text;

    /// ditto
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
        Potential uses: slider widget value out of bounds,
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
    public final string getTclName()
    {
        return _name;
    }

    /** Return the parent widget of this widget, or $(D null) if this widget is the main window. */
    public final @property Widget parentWidget()
    {
        string widgetPath = tclEvalFmt("winfo parent %s", _name);
        return cast(Widget)Widget.lookupWidgetPath(widgetPath);
    }

    /**
        Return the root Window this widget belongs to.

        The window may or may not be the direct parent of this widget,
        you can use $(D rootWindow is parentWidget) to check this.
    */
    public final @property Window rootWindow()
    {
        string widgetPath = tclEvalFmt("winfo toplevel %s", _name);
        return cast(Window)Widget.lookupWidgetPath(widgetPath);
    }

    /**
        Get the configuration options for drag and drop operations for this widget.
    */
    public auto dragDrop()
    {
        return DragDrop(this);
    }

    /**
        The configuration options for drag and drop operations for this widget.
    */
    static struct DragDrop
    {
        @disable this();

        this(Widget widget)
        {
            _widget = widget;
        }

        /** Check whether this widget has been registered for drag & drop operations. */
        bool isRegistered()
        {
            return _widget._isRegisteredDragDrop();
        }

        /** Register the widget to accept drag & drop operations. */
        void register()
        {
            _widget._registerDragDrop();
        }

        /** Unregister the widget. */
        void unregister()
        {
            _widget._unregisterDragDrop();
        }

    private:
        Widget _widget;
    }

    /** Get the string representation of this widget. */
    override string toString() const
    {
        return format("%s(%s)", getClassName(this), _name);
    }

package:

    /* Set a scrollbar for this widget. */
    package final void setScrollbar(Scrollbar scrollbar)
    {
        assert(!scrollbar._name.empty);
        string scrollCommand = format("%sscrollcommand", (scrollbar.orientation == Orientation.horizontal) ? "h" : "y");
        this.setOption(scrollCommand, format("%s set", scrollbar._name));

        string viewTarget = (scrollbar.orientation == Orientation.horizontal) ? "hview" : "yview";
        scrollbar.setOption("command", format("%s %s", this._name, viewTarget));
    }

    package final bool checkState(string state)
    {
        return cast(bool)to!int(tclEvalFmt("%s instate %s", _name, state));
    }

    package final void setState(string state)
    {
        tclEvalFmt("%s state %s", _name, state);
    }

    package final T getOption(T)(string option)
    {
        static if (isArray!T && !isSomeString!T)
        {
            tclEvalFmt("set %s [%s cget -%s]", _dtkScratchArrVar, _name, option);
            return tclGetVar!T(_dtkScratchArrVar);
        }
        else
        {
            return to!T(tclEvalFmt("%s cget -%s", _name, option));
        }
    }

    package final void setOption(T)(string option, T value)
    {
        tclEvalFmt(`%s configure -%s %s`, _name, option, value._tclEscape);
    }

    /**
        Create a Tcl variable.

        The function returns the variable name.
    */
    package static string makeVar()
    {
        string varName = getUniqueVarName();
        tclMakeVar(varName);
        return varName;
    }

    /** Create a unique new callback name. */
    package static string createCallbackName()
    {
        int newSlotID = _lastCallbackID++;
        return format("%s_%s", _callbackPrefix, newSlotID).replace(":", "_");
    }

    /** Create a unique Tcl variable name. */
    package static string getUniqueVarName()
    {
        int newSlotID = _lastVariableID++;
        return format("%s_%s", _variablePrefix, newSlotID);
    }

    /*
        $(B API-only): This is an internal function, $(B do not use in user-code).

        Find the binding of a Tcl widget path and return the
        mapped widget or null if there is no such path mapping.
    */
    public static Widget lookupWidgetPath(in char[] path) /* package */
    {
        if (auto widget = path in _widgetPathMap)
            return *widget;

        return null;
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
    private final void bindTags(TkClass tkClass)
    {
        enforce(!_name.empty);
        tclEvalFmt("bindtags %s [list %s %s %s all ]", _name, _dtkInterceptTag, cast(string)tkClass, _name);
    }

    /** Factored out for delayed initialization. */
    package final void initialize(Widget parent, TkType tkType, string extraOpts = null)
    {
        enforce(parent !is null, "Parent cannot be null");

        /**
            If parent is the root window '.', '.widget' is the widget path.
            If parent is '.frame', '.frame.widget' is the widget path (dot added before widget).
        */
        string prefix;
        if (parent._name != ".")
            prefix = parent._name;

        string name = format("%s.%s%s", prefix, tkType.toString(), _lastWidgetID++);
        tclEvalFmt("%s %s %s", tkType.toBaseType(), name, extraOpts);

        this.initialize(name);

        this.bindTags(tkType.toTkClass());
    }

    /** Init the name. */
    private final void initialize(string name)
    {
        enforce(!name.empty);
        _name = name;
        _widgetPathMap[_name] = this;
        _isInitialized = true;
    }

    /** Check whether this widget has been registered for drag & drop operations. */
    private bool _isRegisteredDragDrop()
    {
        return _dropTarget !is null;
    }

    /** Register the widget to accept drag & drop operations. */
    private void _registerDragDrop()
    {
        if (_dropTarget !is null)
            return;

        _winHandle = getWinHandle(this);

        version (DTK_LOG_COM)
            stderr.writefln("+ Registering d&d  : %X", _winHandle);

        _dropTarget = createDropTarget(this);
        scope (failure)
        {
            _dropTarget = null;
            _winHandle = null;
        }

        registerDragDrop(_winHandle, _dropTarget);

        // widget must be unregistered before Tk's WinHandle (HWND on win32) becomes invalid.
        _onAPIDestroyEvent ~= &_unregisterDragDrop;
    }

    /** Unregister the widget from accepting drag & drop operations. */
    private void _unregisterDragDrop()
    {
        if (_dropTarget is null)
            return;

        version (DTK_LOG_COM)
            stderr.writefln("- Unregistering d&d: %X", _winHandle);

        unregisterDragDrop(_winHandle);
        _dropTarget = null;
        _winHandle = null;
        _onAPIDestroyEvent.disconnect(&_unregisterDragDrop);
    }

    public static void initClass()
    {
        _dtkScratchArrVar = makeVar();
        _dtkDummyWidget = format("%s_%s", _fakeWidgetPrefix, getUniqueVarName());
    }

    /**
        For list retrieval of a Tk widget option (e.g. -values of a spinbox),
        we first assign the values to a Tcl var and then read from it using tclGetVar.
    */
    package static string _dtkScratchArrVar;

    /**
        $(B API-only): This is an internal symbol, $(B do not use in user-code).

        Used to unfocus widgets during a 'tk busy' command
    */
    public static string _dtkDummyWidget;  /* package */

    /**
        $(B API-only): This is an internal symbol, $(B do not use in user-code).

        This widget's unique name.
    */
    public string _name;  /* package */

    /** Counter to create a thread-global unique widget name (_threadID is used in mangling). */
    package static int _lastWidgetID = 0;

    /** Counter to create a unique thread-local callback ID. */
    package static int _lastCallbackID;

    package enum _fakeWidgetPrefix = "dtk_fake_widget";

    /** Prefix for callbacks to avoid name clashes. */
    package enum _callbackPrefix = "dtk::call";

    /** Counter to create a unique thread-local variable ID. */
    package static int _lastVariableID;

    /** Prefix for variables to avoid name clashes. */
    package enum _variablePrefix = "::dtk_var";

    /** Mapping of Tcl widget paths to Widget objects. */
    package static Widget[string] _widgetPathMap;

    /**
        Set when the widget has been initialized. Some delayed-initialized widgets
        can be initialized after construction when initialize is called.
    */
    package bool _isInitialized;

    /**
        Set when the widget is destroyed. This either happens when the destroy()
        method is called or when a parent widget which manages the lifetime of
        the child destroys the child (e.g. $(D tree.destroy(subTree))).
    */
    package bool _isDestroyed;

    /**
        Some widgets are fake, they don't have a Tk equivalent or a valid Tk path,
        but they logically group their child widgets. E.g. a RadioGroup holds
        RadioButton widgets together, even though in Tk there is no such parent-child
        relationship. The flag is needed to avoid calling Tk functions on fake widgets
        since any such call will fail.
    */
    private bool _isFakeWidget;

    /** Set when the widget is registered for drag & drop operations. */
    private DropTarget _dropTarget;

    /** Ditto. */
    private WinHandle _winHandle;

    /**
        $(B API-only): This is an internal symbol, $(B do not use in user-code).

        Release resources for this widget, e.g. COM objects.
    */
    public Signal!DestroyEvent _onAPIDestroyEvent; /* package */
}

/** The dynamic type of a built-in Widget object. */
enum WidgetType
{
    invalid,             /// sentinel
    button,              ///
    checkmenu_item,      ///
    checkbutton,         ///
    combobox,            ///
    entry,               ///
    frame,               ///
    generic_dialog,      ///
    select_dir_dialog,   ///
    select_color_dialog, ///
    image,               ///
    label,               ///
    labelframe,          ///
    listbox,             ///
    list_spinbox,        ///
    messagebox,          ///
    menu,                ///
    menubar,             ///
    menuitem,            ///
    notebook,            ///
    panedwindow,         ///
    progressbar,         ///
    radiogroup_menu,     ///
    radiogroup,          ///
    radiobutton,         ///
    radiomenu_item,      ///
    scalar_spinbox,      ///
    scrollbar,           ///
    separator,           ///
    sizegrip,            ///
    slider,              ///
    text,                ///
    tree,                ///
    window,              ///
    user,                /// User-derived dynamic type
}

// todo: implement later
/** Return the widget type based on the class type. */
/+ template toWidgetType(Class : Widget)
{
    import std.traits;
    import std.typetuple;

    import dtk.image;
    import dtk.widgets;

    alias WidgetTypeList = TypeTuple!(
        Button, CheckMenuItem, CheckButton, Combobox,
        Entry, Frame, GenericDialog, SelectDirDialog,
        SelectColorDialog, Image, Label, LabelFrame,
        Listbox, ListSpinbox, MessageBox, Menu,
        MenuBar, MenuItem, Notebook, PanedWindow,
        Progressbar, RadioGroupMenu, RadioGroup,
        RadioButton, RadioMenuItem, ScalarSpinbox, Scrollbar,
        Separator, Sizegrip, Slider, Text, Tree,
        Window
    );

    alias widgetTypes = EnumMembers!WidgetType;
    static assert(WidgetTypeList.length == widgetTypes.length - 2);  // user and invalid

    enum index = staticIndexOf!(Class, WidgetTypeList);

    static if (index == -1)
        enum toWidgetType = WidgetType.user;
    else
        enum toWidgetType = widgetTypes[index + 1];  // skip 'invalid'
}

///
unittest
{
    static assert(toWidgetType!Button == WidgetType.button);
    static class A : Widget { this() { super(CreateFakeWidget.init, WidgetType.generic_dialog); } }
    static assert(toWidgetType!A == WidgetType.user);
} +/

package struct InitLater { }
package struct CreateFakeWidget { }
package struct CreateToplevel { }
