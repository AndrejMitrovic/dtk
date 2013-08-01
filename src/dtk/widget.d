/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widget;

import std.stdio;
import std.string;
import std.c.stdlib;
import std.conv;

import dtk.options;
import dtk.event;
import dtk.utils;
import dtk.tcl;

public const string HORIZONTAL = "horizontal";
public const string VERTICAL   = "vertical";

/** The callback type of a D event listener. */
alias DtkCallback = void delegate(Widget, Event);

/**
   The main class for all DTK widgets.
*/
abstract class Widget
{
    this()
    {
        _name = ".";
    }

    // todo: insert writeln's here to figure out what syntax is called
    this(Widget master, string wname, Options opt)
    {
        if (master._name == ".")
            _name = "." ~ wname ~ to!string(_lastWidgetID);
        else
            _name = master._name ~ "." ~ wname ~ to!string(_lastWidgetID);

        _lastWidgetID++;
        _interp = master._interp;

        stderr.writefln("tcl_eval { %s }", wname ~ " " ~ _name ~ " " ~ options2string(opt));
        Tcl_Eval(_interp, cast(char*)toStringz(wname ~ " " ~ _name ~ " " ~ options2string(opt)));
    }

    //~ this(Widget master, string wname, Options opt, Callback c)
    //~ {
        //~ _lastWidgetID++;  // todo: this should be shared
        //~ _interp = master._interp;
        //~ int  num  = addCallback(this, c);
        //~ auto mopt = opt;
        //~ mopt["command"] = "" ~ callbackPrefix ~ to!string(num) ~ "";

        //~ if (master._name == ".")
            //~ _name = "." ~ wname ~ to!string(_lastWidgetID);
        //~ else
            //~ _name = master._name ~ "." ~ wname ~ to!string(_lastWidgetID);

        //~ stderr.writefln("tcl_eval { %s }", wname ~ " " ~ _name ~ " " ~ options2string(mopt));
        //~ Tcl_Eval(_interp, cast(char*)toStringz(wname ~ " " ~ _name ~ " " ~ options2string(mopt)));
    //~ }

    /// implemented in derived classes
    public void exit() { }

    /// ditto
    public void clean() { }

    /** Commands. */
    public final void pack()
    {
        eval("pack " ~ _name);
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

    /** Check whether this widget is a foreground widget. */
    public final @property bool isInForeground()
    {
        return !this.isInBackground;
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

    /**
        The widget's value is invalid.
        Potential uses: scale widget value out of bounds,
        entry widget value failed validation.
    */
    public final @property bool isInvalid()
    {
        return this.checkState("invalid");
    }

    /** ditto */
    public final @property bool isValid()
    {
        return !this.isInvalid;
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

    final string eval(string cmd)
    {
        stderr.writefln("tcl_eval { %s }", cmd);

        Tcl_Eval(_interp, cast(char*)toStringz(cmd));
        return to!string(_interp.result);
    }

    final bool checkState(string state)
    {
        string cmd = format("%s instate %s", _name, state);
        return cast(bool)to!int(eval(cmd));
    }

    final void setState(string state)
    {
        string cmd = format("%s state %s", _name, state);
        eval(cmd);
    }

    final T getOption(T)(string option)
    {
        string cmd = format("%s cget -%s", _name, option);
        return to!T(eval(cmd));
    }

    final void setOption(T)(string option, T value)
    {
        string cmd = format(`%s configure -%s %s`, _name, option, value._enquote);
        stderr.writeln(cmd);
        eval(cmd);
    }

    final string createCallback(DtkCallback clb)
    {
        int newSlotID = _lastCallbackID++;  // todo: unsafe with threading

        Command command = Command(this, clb);
        ClientData clientData = cast(ClientData)newSlotID;
        string callbackName = format("%s%s", callbackPrefix, newSlotID);

        Tcl_CreateObjCommand(_interp,
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

package:

    static struct Command
    {
        Widget w;
        DtkCallback c;
    }

    Tcl_Interp* _interp;

    /** Unique widget name. */
    string _name;

    /** Counter to create a unique widget name. */
    static int _lastWidgetID = 0;

    /** Coiunter to create unique callback IDs */
    static int _lastCallbackID;

    enum callbackPrefix = "dtk::call";

    /** All active callbacks. */
    __gshared Command[int] _callbackMap;
}
