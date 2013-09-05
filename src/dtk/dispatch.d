/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.dispatch;

import std.exception;
import std.range;
import std.string;
import std.typecons;

import dtk.widgets.button;
import dtk.widgets.widget;

import dtk.event;
import dtk.geometry;
import dtk.interpreter;
import dtk.keymap;
import dtk.types;
import dtk.utils;

/** The Tcl identifier for the D event callback. */
package enum _dtkCallbackIdent = "dtk::callback_handler";

/** Used for Tcl bindtags. */
package enum _dtkInterceptTag = "dtk::intercept_tag";

/**
    The event dispatch mechanism.
*/
package final abstract class Dispatch
{
static:
    /* API: Initialize the global dtk callback and the dtk interceptor tag bindings. */
    package static void initClass()
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

    // todo: add all bindings here
    private static void _initDtkInterceptor()
    {
        /** Hook keyboard" */

        // Note: We're retrieving a keysym, not a keycode
        static immutable keyboardArgs =
            [TkSubs.keysym_decimal, TkSubs.uni_char, TkSubs.state, TkSubs.widget_path, TkSubs.rel_x_pos, TkSubs.rel_y_pos, TkSubs.abs_x_pos, TkSubs.abs_y_pos, TkSubs.timestamp].join(" ");

        tclEvalFmt("bind %s <KeyPress> { %s %s %s %s }",
            _dtkInterceptTag, _dtkCallbackIdent, EventType.keyboard, KeyboardAction.press, keyboardArgs);

        tclEvalFmt("bind %s <KeyRelease> { %s %s %s %s }",
            _dtkInterceptTag, _dtkCallbackIdent, EventType.keyboard, KeyboardAction.release, keyboardArgs);

        /** Hook mouse. */

        static immutable mouseArgs = [cast(string)TkSubs.mouse_wheel_delta, TkSubs.state, TkSubs.widget_path, TkSubs.rel_x_pos, TkSubs.rel_y_pos, TkSubs.abs_x_pos, TkSubs.abs_y_pos, TkSubs.timestamp].join(" ");

        static mouseButtons = [MouseButton.button1, MouseButton.button2, MouseButton.button3, MouseButton.button4, MouseButton.button5];

        foreach (idx, mouseButton; mouseButtons)
        {
            static immutable modifiers = ["", "Double-", "Triple-", "Quadruple-"];
            static immutable mouseActions = [MouseAction.click, MouseAction.double_click, MouseAction.triple_click, MouseAction.quadruple_click];

            foreach (modifier, mouseAction; zip(modifiers, mouseActions))
            {
                // note: button click can be double clicks, triple clicks, etc.
                tclEvalFmt("bind %s <%sButtonPress-%s> { %s %s %s %s %s }",
                    _dtkInterceptTag, modifier, idx + 1 /* buttons start with 1 */,
                    _dtkCallbackIdent, EventType.mouse, mouseAction, mouseButton, mouseArgs);
            }

            // note: button release does not have a double, triple, equivalent like clicks do.
            tclEvalFmt("bind %s <ButtonRelease-%s> { %s %s %s %s %s }",
                    _dtkInterceptTag, idx + 1,
                    _dtkCallbackIdent, EventType.mouse, MouseAction.release, mouseButton, mouseArgs);
        }

        tclEvalFmt("bind %s <Motion> { %s %s %s %s %s }",
                    _dtkInterceptTag,
                    _dtkCallbackIdent, EventType.mouse, MouseAction.motion, cast(string)TkSubs.mouse_button, mouseArgs);

        tclEvalFmt("bind %s <MouseWheel> { %s %s %s %s %s }",
                    _dtkInterceptTag,
                    _dtkCallbackIdent, EventType.mouse, MouseAction.wheel, cast(string)TkSubs.mouse_button, mouseArgs);
    }

    static extern(C)
    int dtkCallbackHandler(ClientData clientData, Tcl_Interp* interp, int objc, const Tcl_Obj** argArr)
    {
        if (objc < 2)  // DTK event signals need at least 2 arguments
            return TCL_OK;

        /**
            Indices:
                0  => Name of this callback.
                1  => The EventType.
                2+ => The data, based on the Tcl substitutions that we provided for the EventType.
                      EventType-specific handlers take these arguments.
        */

        version (DTK_LOG_EVENTS)
        {
            import std.stdio;
            stderr.writeln("--                --");
            foreach (idx; 0 .. objc)
            {
                stderr.writefln("-- received #%s: %s", idx + 1, argArr[idx].tclGetString());
            }
            stderr.writeln("--                --");
        }

        EventType type = to!EventType(argArr[1].tclPeekString());
        auto args = argArr[2 .. objc];

        switch (type) with (EventType)
        {
            case mouse:    return _handleMouseEvent(args);
            case keyboard: return _handleKeyboardEvent(args);
            case button:   return _handleButtonEvent(args);  // todo: maybe we should return TCL_OK here
            default:       assert(0, format("Unhandled event type '%s'.", type));
        }
    }

    // no-op
    static extern(C)
    void dtkCallbackDeleter(ClientData clientData) { }

    private enum TkEventFlag : uint
    {
        // note: $(D resume) and $(D stop) can only be returned for bind events, not for -command.
        resume = TCL_CONTINUE,
        stop = TCL_BREAK,
        ok = TCL_OK,
    }

    /// create and populate a mouse event and dispatch it.
    private static TkEventFlag _handleMouseEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 10, tclArr.length.text);

        /**
            Indices:
                0 => MouseAction
                1 => Mouse button currently held
                2 => Wheel delta
                3 => Keyboard modifier
                4 => Widget path
                5 => Widget mouse X position
                6 => Widget mouse X position
                7 => Desktop mouse X position
                8 => Desktop mouse Y position
                9 => Timestamp
        */

        MouseAction action = getTclMouseAction(tclArr[0]);
        MouseButton button = getTclMouseButton(tclArr[1]);
        int wheel = getTclMouseWheel(tclArr[2]);
        KeyMod keyMod = getTclKeyMod(tclArr[3]);

        Widget widget = getTclWidget(tclArr[4]);
        assert(widget !is null);

        Point widgetMousePos = getTclPoint(tclArr[5 .. 7]);
        Point desktopMousePos = getTclPoint(tclArr[7 .. 9]);
        TimeMsec timeMsec = getTclTimestamp(tclArr[9]);

        auto event = scoped!MouseEvent(widget, action, button, wheel, keyMod, widgetMousePos, desktopMousePos, timeMsec);
        return _dispatchEvent(widget, event);
    }

    /// create and populate a keyboard event and dispatch it.
    private static TkEventFlag _handleKeyboardEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 10, tclArr.length.text);

        /**
            Indices:
                0  => KeyAction
                1  => KeySym
                2  => Unicode character (can be empty and equal {})
                3  => Modifier
                4  => Widget path
                5  => Widget mouse X position
                6  => Widget mouse X position
                7  => Desktop mouse X position
                8  => Desktop mouse Y position
                9  => Timestamp
        */

        KeyboardAction action = getTclKeyboardAction(tclArr[0]);
        KeySym keySym = getTclKeySym(tclArr[1]);
        char uniChar = getTclUniChar(tclArr[2]);
        KeyMod keyMod = getTclKeyMod(tclArr[3]);

        Widget widget = getTclWidget(tclArr[4]);
        assert(widget !is null);

        Point widgetMousePos = getTclPoint(tclArr[5 .. 7]);
        Point desktopMousePos = getTclPoint(tclArr[7 .. 9]);
        TimeMsec timeMsec = getTclTimestamp(tclArr[9]);

        auto event = scoped!KeyboardEvent(widget, action, keySym, uniChar, keyMod, widgetMousePos, desktopMousePos, timeMsec);
        return _dispatchEvent(widget, event);
    }

    /// create and populate a button event and dispatch it.
    private static TkEventFlag _handleButtonEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 2, tclArr.length.text);

        /**
            Indices:
                0  => ButtonAction
                1  => Widget path
        */

        ButtonAction action = to!ButtonAction(tclArr[0].tclPeekString());

        Widget widget = getTclWidget(tclArr[1]);
        assert(widget !is null);

        // note: timestamp missing since -command doesn't have percent substitution
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!ButtonEvent(widget, action, timeMsec);
        return _dispatchEvent(widget, event);
    }

    /// main dispatch function
    private static TkEventFlag _dispatchEvent(Widget widget, scope Event event)
    {
        /** Handle the filter list, return if filtered. */
        _filterEvent(widget, event);
        if (event.handled)
            return TkEventFlag.stop;

        /** Handle event sinking, return if filtered. */
        _sinkEvent(widget, event);
        if (event.handled)
            return TkEventFlag.stop;

        /** Handle event by the target widget. */
        TkEventFlag result = _targetEvent(widget, event);

        /** Notify any listeners. */
        _notifyEvent(widget, event);

        /** Handle event bubbling, this is the final dispatch stage. */
        _bubbleEvent(widget, event);

        /**
            The filter and sinking stage did not stop the event,
            at this point the event is determined to call other Tk bindtags
            which will e.g. allow a mouse button press event to trigger a
            widget button push event.
        */
        return result;
    }

    /**
        Call all the installed filters for the $(D widget), so they
        get a chance at intercepting the event.
    */
    private static void _filterEvent(Widget widget, scope Event event)
    {
        auto handlers = widget.onFilterEvent.handlers;

        if (handlers.empty)
            return;

        event._eventTravel = EventTravel.filter;

        foreach (filterWidget; handlers)
        {
            filterWidget.call(event);
            if (event.handled)
                return;
        }
    }

    /** Begin the sink event routine if this widget has any parents. */
    private static void _sinkEvent(Widget widget, scope Event event)
    {
        if (auto parent = widget.parentWidget)
        {
            event._eventTravel = EventTravel.sink;
            _sinkEventImpl(parent, event);
        }
    }

    /**
        Find the toplevel widget of $(D widget), and then start
        calling $(D onSinkEvent) on each of these widgets, from the
        toplevel to $(D widget), including $(widget) itself.

        The $(D widget) should already be a parent of the initial
        target widget, since $(D onSinkEvent) will be called on it.
    */
    private static void _sinkEventImpl(Widget widget, scope Event event)
    {
        // climb to the toplevel before sending
        if (auto parent = widget.parentWidget)
            _sinkEventImpl(parent, event);

        // start sending events from the toplevel downwards
        if (event.handled)
            return;

        // handle the sinking event
        widget.onSinkEvent.call(event);
    }

    /**
        Call the generic onEvent on the target widget, or an event-specific handler if
        onEvent doesn't handle the event.
    */
    private static TkEventFlag _targetEvent(Widget widget, scope Event event)
    {
        event._eventTravel = EventTravel.target;
        widget.onEvent.call(event);

        /**
            Most events are set up by 'bind', which allows continue/resume based on
            what the D callback returns. Some events however are set up via -command,
            which doesn't have bindtags, and where returning TCL_CONTINUE/TCL_BREAK
            is invalid, TCL_OK must be returned instead.
        */
        TkEventFlag result = TkEventFlag.resume;

        /** If the generic handler didn't handle it, try a specific handler. */

        // todo: @bug: TkEventFlag.resume will be returned on a command that was handled
        // in the generic onEvent, we should fix this.
        if (!event.handled)
        switch (event.type) with (EventType)
        {
            case user:
                break;  // user events can be handled with onEvent

            case mouse:
                widget.onMouseEvent.call(StaticCast!MouseEvent(event));
                break;

            case keyboard:
                widget.onKeyboardEvent.call(StaticCast!KeyboardEvent(event));
                break;

            case button:
                StaticCast!Button(widget).onButtonEvent.call(StaticCast!ButtonEvent(event));
                result = TkEventFlag.ok;  // -command events can only return TCL_OK
                break;

            default: assert(0, format("Unhandled event type: '%s'", event.type));
        }

        return result;
    }

    /**
        Call all the installed notify listeners for the $(D widget).
    */
    private static void _notifyEvent(Widget widget, scope Event event)
    {
        auto handlers = widget.onNotifyEvent.handlers;

        if (handlers.empty)
            return;

        event._eventTravel = EventTravel.notify;

        foreach (notifyWidget; handlers)
        {
            notifyWidget.call(event);
            if (event.handled)
                return;
        }
    }

    /** Begin the bubble event routine if this widget has any parents. */
    private static void _bubbleEvent(Widget widget, scope Event event)
    {
        if (auto parent = widget.parentWidget)
        {
            event._eventTravel = EventTravel.bubble;
            _bubbleEventImpl(parent, event);
        }
    }

    /**
        Walk from $(D widget) to the toplevel widget by following
        its parent link, while simultaneously calling
        $(D onBubbleEvent) on each widget in the hierarchy.

        The $(D widget) should already be a parent of the initial
        target widget, since $(D onBubbleEvent) will be called on it.
    */
    private static void _bubbleEventImpl(Widget widget, scope Event event)
    {
        // handle the bubbling event
        widget.onBubbleEvent.call(event);

        // if handled, return
        if (event.handled)
            return;

        // else, climb upwards and keep sending
        if (auto parent = widget.parentWidget)
            _bubbleEventImpl(parent, event);
    }

private:
    /** Tcl callback registration state. */
    __gshared bool _dtkCallbackInitialized;
}

/** Extract the integral X and Y points from the 2-dimensional Tcl_Obj array. */
private Point getTclPoint(ref const(Tcl_Obj*)[2] tclArr)
{
    return Point(to!int(tclArr[0].tclPeekString()),
                 to!int(tclArr[1].tclPeekString()));
}

/** Extract the mouse action from the Tcl_Obj object. */
private MouseAction getTclMouseAction(const(Tcl_Obj)* tclObj)
{
    return to!MouseAction(tclObj.tclPeekString());
}

/** Extract the mouse button from the Tcl_Obj object. */
private MouseButton getTclMouseButton(const(Tcl_Obj)* tclObj)
{
    auto buttonStr = tclObj.tclPeekString();
    return (buttonStr == "??") ? MouseButton.none : to!MouseButton(buttonStr);
}

/** Ditto, but interpret the '%d' field which encodes the button that was pressed. */
private MouseButton getTclEncodedMouseButton(const(Tcl_Obj)* tclObj)
{
    auto buttonStr = tclObj.tclPeekString();
    switch (buttonStr)
    {
        case "0": return MouseButton.none;
        case "1": return MouseButton.button1;
        case "2": return MouseButton.button2;
        case "3": return MouseButton.button3;
        case "4": return MouseButton.button4;
        case "5": return MouseButton.button5;
        default:  assert(0, format("Unhandled button '%s'", buttonStr));
    }
}

/** Extract the key modifier from the Tcl_Obj object. */
private KeyMod getTclKeyMod(const(Tcl_Obj)* tclObj)
{
    return cast(KeyMod)to!long(tclObj.tclPeekString());
}

/** Extract the mouse wheel delta from the Tcl_Obj object. */
private int getTclMouseWheel(const(Tcl_Obj)* tclObj)
{
    auto wheelStr = tclObj.tclPeekString();
    return (wheelStr == "??") ? 0 : to!int(wheelStr);
}

/** Extract the key symbol from the Tcl_Obj object. */
private KeySym getTclKeySym(const(Tcl_Obj)* tclObj)
{
    // note: change this to EnumBaseType after Issue 10942 is fixed for KeySym.
    alias keyBaseType = long;
    return to!KeySym(to!keyBaseType(tclObj.tclPeekString()));
}

/** Extract the unicode character from the Tcl_Obj object. */
private char getTclUniChar(const(Tcl_Obj)* tclObj)
{
    auto input = tclObj.tclPeekString();
    return input.empty ? char.init : to!char(input.front);
}

/** Extract the Widget from the Tcl_Obj object. Return null if not found. */
private Widget getTclWidget(const(Tcl_Obj)* tclObj)
{
    return Widget.lookupWidgetPath(tclObj.tclPeekString());
}

/** Extract the timestamp from the Tcl_Obj object. */
private TimeMsec getTclTimestamp(const(Tcl_Obj)* tclObj)
{
    return to!TimeMsec(tclObj.tclPeekString());
}

/** Extract the keyboard action from the Tcl_Obj object. */
private KeyboardAction getTclKeyboardAction(const(Tcl_Obj)* tclObj)
{
    return to!KeyboardAction(tclObj.tclPeekString());
}
