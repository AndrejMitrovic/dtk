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

    // all the event arguments captures by the bind command (todo: %W should be caught)
    // enum string eventArgs = "%W %w %x %y %k %K %h %X %Y";

    // todo: add all bindings here
    private static void _initDtkInterceptor()
    {
        /** Hook keyboard" */

        // Note: We're retrieving keysym, not keycode
        static immutable keyboardArgs =
            [TkSubs.keysym_decimal, TkSubs.uni_char, TkSubs.state, TkSubs.widget_path, TkSubs.rel_x_pos, TkSubs.rel_y_pos, TkSubs.abs_x_pos, TkSubs.abs_y_pos, TkSubs.timestamp].join(" ");

        tclEvalFmt("bind %s <KeyPress> { %s %s %s }",
            _dtkInterceptTag, _dtkCallbackIdent, EventType.keyboard, keyboardArgs);

        /** Hook mouse. */

        //~ static immutable mouseArgs =
            //~ [TkSubs.mouse_button, TkSubs.state, TkSubs.widget_path].join(" ");

        //~ tclEvalFmt("bind %s <KeyPress> { %s %s %s }",
            //~ _dtkInterceptTag, _dtkCallbackIdent, EventType.keyboard, mouseArgs);

        //~ tclEvalFmt(`bind %s <Button-1> "%s %s"`, _dtkInterceptTag, _dtkCallbackIdent, tcl_flags);
    }

    //~ static auto safeToInt(T)(T* val)
    //~ {
        //~ auto res = to!string(val);
        //~ if (res == "??")  // note: edge-case, but there might be more of them
            //~ return 0;    // note2: "0" is just a guess, not sure what else to set it to.

        //~ return to!int(res);
    //~ }

    private enum TkEventFlag : uint
    {
        // note: $(D resume) and $(D stop) can only be returned for bind events, not for -command.
        resume = TCL_CONTINUE,
        stop = TCL_BREAK,
        ok = TCL_OK,
    }

    /// create and populate a mouse event, and dispatch it.
    //~ private static TkEventFlag _handleMouseEvent(const Tcl_Obj*[] tclArr)
    //~ {
        //~ stderr.writefln("Key code: %s", cast(KeySym)to!long(tclArr[0].tclPeekString()));

        //~ assert(tclArr.length == 4, tclArr.length.text);

        /**
            Indices:
                0  => KeySym
                1  => Modifier
                2  => Widget path
                3  => Timestamp
        */

        // note: change this to EnumBaseType after Issue 10942 is fixed for KeySym.
        //~ alias keyBaseType = long;

        //~ KeySym keySym = to!KeySym(to!keyBaseType(tclArr[0].tclPeekString()));

        //~ KeyMod keyMod = cast(KeyMod)to!long(tclArr[1].tclPeekString());

        //~ Widget widget = lookupWidgetPath(tclArr[2].tclPeekString());
        //~ assert(widget !is null);

        //~ TimeMsec timeMsec = to!TimeMsec(tclArr[3].tclPeekString());

        //~ auto event = scoped!MouseEvent(widget, keySym, keyMod, timeMsec);
        //~ return _dispatchEvent(widget, event);
    //~ }

    /// create and populate a keyboard event, and dispatch it.
    private static TkEventFlag _handleKeyboardEvent(const Tcl_Obj*[] tclArr)
    {
        //~ stderr.writefln("Key code: %s", cast(KeySym)to!long(tclArr[0].tclPeekString()));

        assert(tclArr.length == 9, tclArr.length.text);

        /**
            Indices:
                0  => KeySym
                1  => Unicode character (can be empty and equal {})
                2  => Modifier
                3  => Widget path
                4  => Widget mouse X position
                5  => Widget mouse X position
                6  => Desktop mouse X position
                7  => Desktop mouse Y position
                8  => Timestamp
        */

        // note: change this to EnumBaseType after Issue 10942 is fixed for KeySym.
        alias keyBaseType = long;

        KeySym keySym = to!KeySym(to!keyBaseType(tclArr[0].tclPeekString()));

        auto input = tclArr[1].tclPeekString();
        //~ stderr.writefln("input: %s", input);

        char uniChar = input.empty ? char.init : to!char(input.front);

        //~ stderr.writefln("unichar: %s", uniChar);

        KeyMod keyMod = cast(KeyMod)to!long(tclArr[2].tclPeekString());

        Widget widget = Widget.lookupWidgetPath(tclArr[3].tclPeekString());
        assert(widget !is null);

        Point widgetMousePos = Point(to!int(tclArr[4].tclPeekString()),
                                     to!int(tclArr[5].tclPeekString()));

        Point desktopMousePos = Point(to!int(tclArr[6].tclPeekString()),
                                      to!int(tclArr[7].tclPeekString()));

        TimeMsec timeMsec = to!TimeMsec(tclArr[8].tclPeekString());

        auto event = scoped!KeyboardEvent(widget, keySym, uniChar, keyMod, widgetMousePos, desktopMousePos, timeMsec);
        return _dispatchEvent(widget, event);
    }

    /// create and populate a button event, and dispatch it.
    private static TkEventFlag _handleButtonEvent(const Tcl_Obj*[] tclArr)
    {
        //~ stderr.writefln("Key code: %s", cast(KeySym)to!long(tclArr[0].tclPeekString()));

        assert(tclArr.length == 2, tclArr.length.text);

        /**
            Indices:
                0  => ButtonAction
                1  => Widget path
        */

        //~ stderr.writefln("-- received #0: %s", tclArr[0].tclPeekString());
        //~ stderr.writefln("-- received #1: %s", tclArr[1].tclPeekString());

        ButtonAction action = to!ButtonAction(tclArr[0].tclPeekString());

        Widget widget = Widget.lookupWidgetPath(tclArr[1].tclPeekString());
        assert(widget !is null);

        // note: timestamp missing since -command doesn't have percent substitution
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!ButtonEvent(widget, action, timeMsec);
        return _dispatchEvent(widget, event);
    }

    /// create and populate a mouse event, and dispatch it.
    //~ private static TkEventFlag _handleMouseEvent(const Tcl_Obj*[] tclArr)
    //~ {
        //~ auto event = scoped!MouseEvent();
        //~ return _dispatchEvent(event);
    //~ }

    /// main dispatch function
    private static TkEventFlag _dispatchEvent(Widget widget, scope Event event)
    {
        //~ stderr.writefln("Dispatching %s %s", widget, event);

        /** Handle the filter list, return if filtered. */
        _filterEvent(widget, event);
        if (event.handled)
            return TkEventFlag.stop;

        /** Handle event sinking, return if filtered. */
        _sinkEvent(widget, event);
        if (event.handled)
            return TkEventFlag.stop;

        /** Handle event by the target widget itself. */
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
                result = TkEventFlag.ok;  // -command events do not have continue/break
                break;

            default: assert(0, format("Unhandled event type: '%s'", event.type));
        }

        /** Notify any listeners. */
        _notifyEvent(widget, event);

        /** Handle event bubbling, this is the final travel stage. */
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

    static extern(C)
    int dtkCallbackHandler(ClientData clientData, Tcl_Interp* interp, int objc, const Tcl_Obj** argArr)
    {
        if (objc < 2)  // DTK event signals need at least 2 arguments
            return TCL_OK;

        // todo: store %t in the first run as _timeBegin, and then use %t - _timeBegin to calculate
        // a Duration type (e.g. fromMsecs or similar).

        // todo: store a Point() struct for the mouse point.
        // todo:

        /**
            Indices:
                0  => Name of this callback.
                1  => The EventType.
                2  => Detailed subtype of EventType, MouseAction for specific buttons.
                2+ => The data, based on the Tcl substitutions that we provided for the EventType.

            The 1 + 2 event type tags are implemented this way to allow separating out event handlers
            into separate functions.
        */

        version (DTK_LOG_EVENTS)
        {
            import std.stdio;
            foreach (idx; 0 .. objc)
            {
                stderr.writefln("-- received #%s: %s", idx + 1, argArr[idx].tclPeekString());
            }
        }

        EventType type = to!EventType(argArr[1].tclPeekString());
        auto args = argArr[2 .. objc];

        switch (type) with (EventType)
        {
            case mouse:    return TCL_OK;  // return _handleMouseEvent(args);
            case keyboard: return _handleKeyboardEvent(args);
            case button:   return _handleButtonEvent(args);
            default:       assert(0, format("Unhandled event type '%s'.", type));
        }
    }

    // no-op
    static extern(C)
    void dtkCallbackDeleter(ClientData clientData) { }

    /** Is the Tcl callback registered. */
    __gshared bool _dtkCallbackInitialized;
}

private void _oldValidation()
{
    //~ return TCL_OK;

    // todo: use try/catch on a Throwable, we don't want to escape exceptions to the C side.
    // todo: extract the types, and the event type, and the direct it to a D function that can

   /+  int slotID = cast(int)clientData;

    if (auto callback = slotID in _callbackMap)
    {
        Event event;  // todo: update

        if (objc > 1)  // todo: objc is the argArr count, not sure if we should always assign all fields
        {
            try
            {
                event.type = tclConv!TkEventType(Tcl_GetString(argArr[1]));
            }
            catch (ConvException ce)
            {
                stderr.writefln("Couldn't convert: `%s`", to!string(Tcl_GetString(argArr[1])));
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
                    event.state = to!string(Tcl_GetString(argArr[2]));
                    break;
                }

                case TkValidate:
                case TkFailedValidation:
                {
                    string validEventArgs = to!string(Tcl_GetString(argArr[2]));

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
                            //~ stderr.writefln("arg %s: %s", idx, to!string(Tcl_GetString(argArr[idx])));
                            event.tupleof[idx - 1] = tclConv!(typeof(event.tupleof[idx - 1]))(Tcl_GetString(argArr[idx]));
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
