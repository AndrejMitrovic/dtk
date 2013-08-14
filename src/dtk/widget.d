/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widget;

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
import dtk.entry;
import dtk.event;
import dtk.geometry;
import dtk.options;
import dtk.signals;
import dtk.scrollbar;
import dtk.types;
import dtk.utils;

/// Tk and Ttk widget types
package enum TkType : string
{
    button = "ttk::button",
    checkbutton = "ttk::checkbutton",
    combobox = "ttk::combobox",
    entry = "ttk::entry",
    frame = "ttk::frame",
    label = "ttk::label",
    listbox = "tk::listbox",  // note: no ttk::listbox yet in v8.6
    radiobutton = "ttk::radiobutton",
    sizegrip = "ttk::sizegrip",
    scrollbar = "ttk::scrollbar",
    toplevel = "tk::toplevel"
}

/** The main class of all Dtk widgets. */
abstract class Widget
{
    this(Widget parent, TkType tkType, DtkOptions opt, EmitGenericSignals emitGenericSignals = EmitGenericSignals.yes)
    {
        this(parent, tkType, emitGenericSignals, opt.options2string);
    }

    // ctor with formatted options
    this(Widget parent, TkType tkType, EmitGenericSignals emitGenericSignals = EmitGenericSignals.yes, string opts = "")
    {
        string prefix;  // '.' is the root window
        if (parent !is null && parent._name != ".")
            prefix = parent._name;

        string name = format("%s.%s%s%s", prefix, tkType.toString(), _threadID, _lastWidgetID++);
        this.evalFmt("%s %s %s", tkType.toBaseType(), name, opts);

        this(name, emitGenericSignals);
    }

    package this(string name, EmitGenericSignals emitGenericSignals)
    {
        _name = name;
        _widgetPathMap[_name] = this;
        _eventCallbackIdent = this.createCallback(&onEvent);

        if (emitGenericSignals == EmitGenericSignals.yes)
        {
            this.evalFmt("bind %s <Enter> { %s %s %s }", _name, _eventCallbackIdent, EventType.Enter, eventArgs);
            this.evalFmt("bind %s <Leave> { %s %s %s }", _name, _eventCallbackIdent, EventType.Leave, eventArgs);
        }
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
    public Signal!(Widget, Event) onEvent;

    /// implemented in derived classes
    public void exit() { }

    /// implemented in derived classes
    public void clean() { }

    /** Commands: */

    // todo: this should be moved to a layout module
    public final void pack()
    {
        evalFmt("pack %s", _name);
    }

    /** Options: */

    /** Get the 0-based index of the underlined character, or -1 if no character is underlined. */
    @property int underline()
    {
        return this.getOption!int("underline");
    }

    /** Set the underlined character at the 0-based index. */
    @property void underline(int charIndex)
    {
        this.setOption("underline", charIndex);
    }

    /** Get the text string displayed in the widget. */
    @property string text()
    {
        return this.getOption!string("text");
    }

    /** Set the text string displayed in the widget. */
    @property void text(string newText)
    {
        this.setOption("text", newText);
    }

    /**
        Get the text label space width currently set.
        If no specific text width is set, 0 is returned,
        which implies a natural text space width is used.
    */
    @property int width()
    {
        string input = this.getOption!string("width");
        if (input.empty)
            return 0;

        return to!int(input);
    }

    /**
        Set the text label space width. If greater than zero, specifies how much space
        in character widths to allocate for the text label. If less than zero,
        specifies a minimum width. If zero or unspecified, the natural width of
        the text label is used.
    */
    @property void width(int newWidth)
    {
        this.setOption("width", newWidth);
    }

    /** State modifiers: */

    /** Enable this widget. */
    public final void enable()
    {
        this.setState("!disabled");
    }

    /** Disable this widget. */
    public final void disable()
    {
        this.setState("disabled");
    }

    /**
        Get the current widget style.

        Use the derived-class $(D style)
        properties to get a specific style.
    */
    @property string genericStyle()
    {
        return this.getOption!string("style");
    }

    /**
        Set the widget style.

        Use the derived-class $(D style)
        properties to set a specific style.
    */
    @property void genericStyle(string newStyle)
    {
        this.setOption("style", newStyle);
    }

    /** State checks: */

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

    /** Check whether this widget is disabled. */
    public final @property bool isDisabled()
    {
        return this.checkState("disabled");
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
    void focus()
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

    /** Destroy this widget. */
    public void destroy()
    {
        this.evalFmt("destroy %s", _name);
    }

    /** Get the underlying Tcl widget name. Use with debugging and eval calls. */
    public string getTclName()
    {
        return _name;
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
        return eval(format(fmt, args));
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

    final void setOption(T)(string option, T value)
    {
        evalFmt(`%s configure -%s %s`, _name, option, value._enquote);
    }

    final T getVar(T)(string varName)
    {
        // todo: use TCL_LEAVE_ERR_MSG
        // todo: check _interp error
        // tood: check all interpreter error codes

        enum getFlags = 0;
        static if (isArray!T)
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
            Tcl_SetVar(App._interp, cast(char*)varName.toStringz, cast(char*)(value.toStringz), setFlags);
        }
    }

    /** Create a unique new callback name. */
    static string createCallbackName()
    {
        int newSlotID = _lastCallbackID++;
        return format("%s%s_%s", callbackPrefix, _threadID, newSlotID).replace(":", "_");
    }

    /** Create a Tcl callback. */
    string createCallback(Signal!(Widget, Event)* signal)
    {
        int newSlotID = _lastCallbackID++;

        ClientData clientData = cast(ClientData)newSlotID;
        string callbackName = format("%s%s_%s", callbackPrefix, _threadID, newSlotID);

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
        return format("%s%s_%s", variablePrefix, _threadID, newSlotID);
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
    string _name;

    /** Counter to create a thread-global unique widget name (_threadID is used in mangling). */
    static int _lastWidgetID = 0;

    /** Counter to create a unique thread-local callback ID. */
    static int _lastCallbackID;

    /** Prefix for callbacks to avoid name clashes. */
    enum callbackPrefix = "dtk::call";

    /** Counter to create a unique thread-local variable ID. */
    static int _lastVariableID;

    /** Prefix for variables to avoid name clashes. */
    enum variablePrefix = "::dtk_var";

    static struct Callback
    {
        Widget widget;
        Signal!(Widget, Event)* signal;
    }

    /** All thread-local active callbacks. */
    static Callback[int] _callbackMap;

    /** All widget paths -> widget maps */
    static Widget[string] _widgetPathMap;
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
package T toBaseType(E, T = EnumBaseType!E)(E val)
{
    return cast(T)val;
}
