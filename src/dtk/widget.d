/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widget;

import core.thread;

import std.stdio;
import std.string;
import std.c.stdlib;
import std.conv;

import dtk.app;
import dtk.options;
import dtk.event;
import dtk.types;
import dtk.utils;

/** The callback type of a D event listener. */
alias DtkCallback = void delegate(Widget, Event);

/** The main class of all Dtk widgets. */
abstract class Widget
{
    this(string name)
    {
        _name = name;
        _widgetPathMap[_name] = this;
    }

    // todo: replace tkType with an enum
    this(Widget parent, string tkType, DtkOptions opt)
    {
        string prefix;  // '.' is the root window
        if (parent !is null && parent._name != ".")
            prefix = parent._name;

        _name = format("%s.%s%s%s", prefix, tkType, _threadID, _lastWidgetID++);
        evalFmt("%s %s %s", tkType, _name, options2string(opt));
        _widgetPathMap[_name] = this;
    }

    /// implemented in derived classes
    public void exit() { }

    /// implemented in derived classes
    public void clean() { }

    /** Commands: */

    //~ public final void pack()
    //~ {
        //~ evalFmt("pack %s", _name);
    //~ }

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
        try
        {
            return this.getOption!int("width");
        }
        catch (ConvException)
        {
            return 0;
        }
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

package:

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

    /** Create a callback that will refrence this widget. */
    final string createCallback(DtkCallback clb)
    {
        int newSlotID = _lastCallbackID++;

        Command command = Command(this, clb);
        ClientData clientData = cast(ClientData)newSlotID;
        string callbackName = format("%s%s", callbackPrefix, newSlotID);

        Tcl_CreateObjCommand(App._interp,
                             cast(char*)callbackName.toStringz,
                             &callbackHandler,
                             clientData,
                             &callbackDeleter);

        _callbackMap[newSlotID] = command;
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
            Event event;

            if (objc > 1)  // todo: objc is the objv count, not sure if we should always assign all fields
            {
                // http://tmml.sourceforge.net/doc/tcl/CrtObjCmd.html
                event.x       = safeToInt(Tcl_GetString(objv[1]));
                event.y       = safeToInt(Tcl_GetString(objv[2]));
                event.keycode = safeToInt(Tcl_GetString(objv[3]));
                event.width   = safeToInt(Tcl_GetString(objv[4]));
                event.height  = safeToInt(Tcl_GetString(objv[5]));
                event.width   = safeToInt(Tcl_GetString(objv[6]));
                event.height  = safeToInt(Tcl_GetString(objv[7]));
            }

            callback.c(callback.w, event);
            return TCL_OK;
        }
        else
        {
            Tcl_SetResult(interp, cast(char*)"Trying to invoke non-existent callback", TCL_STATIC);
            return TCL_ERROR;
        }
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

    static struct Command
    {
        Widget w;
        DtkCallback c;
    }

    /** All thread-local active callbacks. */
    static Command[int] _callbackMap;

    /** All widget paths -> widget maps */
    static Widget[string] _widgetPathMap;
}
