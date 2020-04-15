/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.dispatch;

import dtk.event;
import dtk.geometry;
import dtk.imports;
import dtk.interpreter;
import dtk.keymap;
import dtk.types;
import dtk.utils;

import dtk.widgets;

/** Name of the D event callback. */
package enum _dtkCallbackIdent = "dtk::callback_handler";

/** Name of the procedure for focus requests. */
package enum _dtkFocusCallbackIdent = "dtk::focus_request";

/** Used for Tcl bindtags. */
package enum _dtkInterceptTag = "dtk::intercept_tag";

package enum _dtkFocusTempVar = "dtk::focus_state_var";

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

    private static void _initDtkInterceptor()
    {
        /** Hook keyboard" */

        // Note: We're retrieving a keysym, not a keycode
        static immutable keyboardArgs =
            [TkSubs.keysym_decimal, TkSubs.uni_char, TkSubs.state, TkSubs.widget_path, TkSubs.rel_x_pos, TkSubs.rel_y_pos, TkSubs.abs_x_pos, TkSubs.abs_y_pos, TkSubs.timestamp].map!(arg => cast(string)arg).join(" ");

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

        /** Hook geometry. */

        static immutable geometryArgs = [TkSubs.widget_path, TkSubs.rel_x_pos, TkSubs.rel_y_pos, TkSubs.width, TkSubs.height, TkSubs.border_width]
            .map!(arg => cast(string)arg).join(" ");

        tclEvalFmt("bind %s <Configure> { %s %s %s }",
                    _dtkInterceptTag,
                    _dtkCallbackIdent, EventType.geometry, geometryArgs);

        /** Hook hover. */

        static immutable hoverArgs = [TkSubs.widget_path, TkSubs.rel_x_pos, TkSubs.rel_y_pos, TkSubs.state, TkSubs.timestamp].map!(arg => cast(string)arg).join(" ");

        tclEvalFmt("bind %s <Enter> { %s %s %s %s }",
                    _dtkInterceptTag,
                    _dtkCallbackIdent, EventType.hover, HoverAction.enter, hoverArgs);

        tclEvalFmt("bind %s <Leave> { %s %s %s %s }",
                    _dtkInterceptTag,
                    _dtkCallbackIdent, EventType.hover, HoverAction.leave, hoverArgs);

        /** Hook focus. */

        tclEvalFmt("bind %s <FocusIn> { %s %s %s %s }",
                    _dtkInterceptTag,
                    _dtkCallbackIdent, EventType.focus, FocusAction.focus, cast(string)TkSubs.widget_path);

        tclEvalFmt("bind %s <FocusOut> { %s %s %s %s }",
                    _dtkInterceptTag,
                    _dtkCallbackIdent, EventType.focus, FocusAction.unfocus, cast(string)TkSubs.widget_path);

        //~ /** Inject procedure for focus requests. */
        tclEvalFmt("
        proc %s {w} {
            %s %s %s $w

            if {$dtk::focus_state_var eq 1} {
                return 1
            } else {
                return 0
            }
        }", _dtkFocusCallbackIdent, _dtkCallbackIdent, EventType.focus, FocusAction.request);

        /** Store the result to this var in ttk::takefocus calls. */
        tclMakeVar(_dtkFocusTempVar);

        /** Hook user destroy event by appending. */
        tclEvalFmt("bind %s <Destroy> { %s %s %s }",
                    _dtkInterceptTag,
                    _dtkCallbackIdent, EventType.destroy, cast(string)TkSubs.widget_path);

        /** Hook listbox select virtual event. */
        tclEvalFmt("bind %s <<ListboxSelect>> { %s %s %s %s}",
            _dtkInterceptTag, _dtkCallbackIdent, EventType.listbox, "%W", ListboxAction.select);
    }

    package alias dtkCallbackHandler = ThrowWrapper!dtkCallbackHandlerImpl;

    package static int dtkCallbackHandlerImpl(ClientData clientData, Tcl_Interp* interp, int objc, const Tcl_Obj** argArr)
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
            stderr.writeln("--                --");
            foreach (idx; 0 .. objc)
            {
                stderr.writefln("-- received #%s: %s", idx + 1, argArr[idx].tclPeekString());
            }
            stderr.writeln("--                --");
        }

        EventType type = to!EventType(argArr[1].tclPeekString());
        auto args = argArr[2 .. objc];

        switch (type) with (EventType)
        {
            // case user:     return _handleUserEvent(args);  // todo
            case mouse:    return _handleMouseEvent(args);
            case keyboard: return _handleKeyboardEvent(args);
            case geometry: return _handleGeometryEvent(args);
            case hover:    return _handleHoverEvent(args);
            case focus:    return _handleFocusEvent(args);
            case destroy:  return _handleDestroyEvent(args);

            case button:
                _handleButtonEvent(args);
                goto ok_event;

            case check_button:
                _handleCheckButtonEvent(args);
                goto ok_event;

            case menu:
                _handleMenuEvent(args);
                goto ok_event;

            case combobox:
                _handleComboboxEvent(args);
                goto ok_event;

            case entry:
                _handleEntryEvent(args);
                goto ok_event;

            case validate:
                _handleValidateEvent(args);
                goto ok_event;

            case listbox:
                _handleListboxEvent(args);
                goto ok_event;

            case radio_button:
                _handleRadioButtonEvent(args);
                goto ok_event;

            case slider:
                _handleSliderEvent(args);
                goto ok_event;

            case scalar_spinbox:
                _handleScalarSpinboxEvent(args);
                goto ok_event;

            case list_spinbox:
                _handleListSpinboxEvent(args);
                goto ok_event;

            /**
                Most events are set up by 'bind', which allows continue/resume based on
                what the D callback returns. Some events however are set up via -command,
                which doesn't support bindtags. Returning TCL_CONTINUE/TCL_BREAK is invalid,
                TCL_OK must be returned instead.
            */
            ok_event:
                return TkEventFlag.ok;

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
        dchar unichar = getTclUnichar(tclArr[2]);
        KeyMod keyMod = getTclKeyMod(tclArr[3]);

        Widget widget = getTclWidget(tclArr[4]);
        assert(widget !is null);

        Point widgetMousePos = getTclPoint(tclArr[5 .. 7]);
        Point desktopMousePos = getTclPoint(tclArr[7 .. 9]);
        TimeMsec timeMsec = getTclTimestamp(tclArr[9]);

        auto event = scoped!KeyboardEvent(widget, action, keySym, unichar, keyMod, widgetMousePos, desktopMousePos, timeMsec);
        return _dispatchEvent(widget, event);
    }

    /// create and populate a geometry event and dispatch it.
    private static TkEventFlag _handleGeometryEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 6, tclArr.length.text);

        /**
            Indices:
                0  => Widget path
                1  => Widget x position
                2  => Widget y position
                3  => Widget width
                4  => Widget height
                5  => Widget border width
        */

        Widget widget = getTclWidget(tclArr[0]);
        assert(widget !is null);

        Point position = getTclPoint(tclArr[1 .. 3]);
        Size size = getTclSize(tclArr[3 .. 5]);
        int borderWidth = to!int(tclArr[5].tclPeekString());

        // note: timestamp missing since <Configure> event doesn't support timestamps
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!GeometryEvent(widget, position, size, borderWidth, timeMsec);
        return _dispatchEvent(widget, event);
    }

    /// create and populate a hover event and dispatch it.
    private static TkEventFlag _handleHoverEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 6, tclArr.length.text);

        /**
            Indices:
                0  => HoverAction
                1  => Widget path
                2  => Mouse x position
                3  => Mouse y position
                4  => Key modifier
                5  => Timestamp
        */

        HoverAction hoverAction = to!HoverAction(tclArr[0].tclPeekString());

        Widget widget = getTclWidget(tclArr[1]);
        assert(widget !is null);

        Point position = getTclPoint(tclArr[2 .. 4]);

        KeyMod keyMod = getTclKeyMod(tclArr[4]);

        // note: timestamp missing since <Configure> event doesn't support timestamps
        TimeMsec timeMsec = getTclTimestamp(tclArr[5]);

        auto event = scoped!HoverEvent(widget, hoverAction, position, keyMod, timeMsec);
        return _dispatchEvent(widget, event);
    }

    /// create and populate a focus event and dispatch it.
    private static int _handleFocusEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 2, tclArr.length.text);

        /**
            Indices:
                0  => FocusAction
                1  => Widget path
        */

        FocusAction focusAction = to!FocusAction(tclArr[0].tclPeekString());

        Widget widget = getTclWidget(tclArr[1]);
        assert(widget !is null, tclArr[1].tclPeekString());

        // note: timestamp missing since <FocusIn/FocusOut> event doesn't support timestamps
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!FocusEvent(widget, focusAction, timeMsec);
        auto result = _dispatchEvent(widget, event);

        if (focusAction == FocusAction.request)
        {
            int res = event._allowFocus ? widget.allowFocus : 0;
            //~ stderr.writefln("Focus event request result: %s", event._allowFocus);
            //~ stderr.writefln("Focus widget request result: %s", widget._allowFocus);
            //~ tclEvalFmt("set %s %s", _dtkFocusTempVar, res);
            tclSetVar(_dtkFocusTempVar, res);
            return TCL_OK;
        }
        else
        {
            return result;
        }
    }

    /// create and populate a destroy event and dispatch it.
    private static TkEventFlag _handleDestroyEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 1, tclArr.length.text);

        /**
            Indices:
                0  => Widget path
        */

        Widget widget = getTclWidget(tclArr[0]);
        assert(widget !is null);

        // note: timestamp missing since <Destroy> event doesn't support timestamps
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!DestroyEvent(widget, timeMsec);
        return _dispatchEvent(widget, event);
    }

    /// create and populate a button event and dispatch it.
    private static void _handleButtonEvent(const Tcl_Obj*[] tclArr)
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
        _dispatchEvent(widget, event);
    }

    /// create and populate a check button event and dispatch it.
    private static void _handleCheckButtonEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 1, tclArr.length.text);

        /**
            Indices:
                0  => Widget path
        */

        Widget widget = getTclWidget(tclArr[0]);
        assert(widget !is null);

        assert(widget.widgetType == WidgetType.checkbutton);
        CheckButton button = StaticCast!CheckButton(widget);

        // will be left in Invalid state if value does not match
        CheckButtonAction action;
        if (button.value == button.onValue)
            action = CheckButtonAction.toggleOn;
        else
        if (button.value == button.offValue)
            action = CheckButtonAction.toggleOff;

        // note: timestamp missing since -command doesn't have percent substitution
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!CheckButtonEvent(widget, action, timeMsec);
        _dispatchEvent(widget, event);
    }

    /// create and populate a menu event and dispatch it.
    private static void _handleMenuEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 3, tclArr.length.text);

        /**
            Indices:
                0  => MenuAction
                1  => MenuBar widget path
                2  => Target menu item widget path
        */

        MenuAction action = to!MenuAction(tclArr[0].tclPeekString());

        CommonMenu rootMenu = cast(CommonMenu)getTclWidget(tclArr[1]);
        assert(rootMenu !is null);

        Widget menuItem = getTclWidget(tclArr[2]);
        assert(menuItem !is null);

        // note: timestamp missing since -command doesn't have percent substitution
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!MenuEvent(menuItem, action, rootMenu, timeMsec);
        _dispatchEvent(rootMenu, event);
    }

    /// create and populate a combobox event and dispatch it.
    private static void _handleComboboxEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 4, tclArr.length.text);

        /**
            Indices:
                0  => Combobox widget path

            Ignored, but implicitly passed by Tk:
                1  => Name of the global traced variable
                2  => Empty
                3  => command (write or read). We only track writes.
        */

        Widget widget = getTclWidget(tclArr[0]);
        assert(widget !is null);

        // note: timestamp missing since -command doesn't have percent substitution
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!ComboboxEvent(widget, timeMsec);
        _dispatchEvent(widget, event);
    }

    /// create and populate an entry event and dispatch it.
    private static void _handleEntryEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 4, tclArr.length.text);

        /**
            Indices:
                0  => Entry widget path

            Ignored, but implicitly passed by Tk:
                1  => Name of the global traced variable
                2  => Empty
                3  => command (write or read). We only track writes.
        */

        Widget widget = getTclWidget(tclArr[0]);
        assert(widget !is null);

        // note: timestamp missing since -command doesn't have percent substitution
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!EntryEvent(widget, timeMsec);
        _dispatchEvent(widget, event);
    }

    /// create and populate a validate event and dispatch it.
    private static void _handleValidateEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 8, tclArr.length.text);

        /**
            Indices:
                0  => Entry widget path
                1  => Type of action - 1 for insert prevalidation, 0 for delete prevalidation, or -1 for revalidation.
                2  => Index of character string to be inserted/deleted
                3  => In prevalidation, the new value of the entry if the edit is accepted. In revalidation, the current value of the entry.
                4  => The current value of entry prior to editing.
                5  => The text string being inserted/deleted, if any.
                6  => The current value of the -validate option
                7  => The validation condition that triggered the callback (key, focusin, focusout, or forced).
        */

        Entry widget = cast(Entry)getTclWidget(tclArr[0]);
        assert(widget !is null);

        ValidateAction action = getTclValidateAction(tclArr[1]);

        sizediff_t charIndex = to!sizediff_t(tclArr[2].tclPeekString());

        auto newValue = tclArr[3].tclPeekString().idup;
        auto oldValue = tclArr[4].tclPeekString().idup;
        auto editValue = tclArr[5].tclPeekString().idup;

        ValidateMode validateMode = getTclValidateMode(tclArr[6]);

        ValidateMode validateCondition = getTclValidateMode(tclArr[7]);

        // note: timestamp missing since -command doesn't have percent substitution
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!ValidateEvent(widget, action, charIndex, newValue, oldValue, editValue, validateMode, validateCondition, timeMsec);
        _dispatchEvent(widget, event);

        widget._setValidateState(event.validated);
    }

    /// create and populate a listbox event and dispatch it.
    private static void _handleListboxEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 2 || tclArr.length == 5, tclArr.length.text);

        /**
            Indices:
                0  => Listbox widget path
                1  => Listbox action

            Ignored, but implicitly passed by Tk when action equals "edit"
                2  => Name of the global traced variable
                3  => Empty
                4  => command (write or read). We only track writes.
        */

        Listbox widget = cast(Listbox)getTclWidget(tclArr[0]);
        assert(widget !is null);

        ListboxAction action = getTclListboxAction(tclArr[1]);

        // note: timestamp missing since -command doesn't have percent substitution
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!ListboxEvent(widget, action, timeMsec);
        _dispatchEvent(widget, event);
    }

    /// create and populate a radio button event and dispatch it.
    private static void _handleRadioButtonEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 4, tclArr.length.text);

        /**
            Indices:
                0  => RadioGroup widget path

            Ignored, but implicitly passed by Tk when action equals "edit"
                1  => Name of the global traced variable
                2  => Empty
                3  => command (write or read). We only track writes.
        */

        Widget widget = getTclWidget(tclArr[0]);
        assert(widget !is null);

        // note: timestamp missing since -command doesn't have percent substitution
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!RadioButtonEvent(widget, timeMsec);
        _dispatchEvent(widget, event);
    }

    /// create and populate a slider event and dispatch it.
    private static void _handleSliderEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 4, tclArr.length.text);

        /**
            Indices:
                0  => Slider widget path

            Ignored, but implicitly passed by Tk when action equals "edit"
                1  => Name of the global traced variable
                2  => Empty
                3  => command (write or read). We only track writes.
        */

        Widget widget = getTclWidget(tclArr[0]);
        assert(widget !is null);

        // note: timestamp missing since -command doesn't have percent substitution
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!SliderEvent(widget, timeMsec);
        _dispatchEvent(widget, event);
    }

    /// create and populate a scalar spinbox event and dispatch it.
    private static void _handleScalarSpinboxEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 4, tclArr.length.text);

        /**
            Indices:
                0  => ScalarSpinbox widget path

            Ignored, but implicitly passed by Tk when action equals "edit"
                1  => Name of the global traced variable
                2  => Empty
                3  => command (write or read). We only track writes.
        */

        Widget widget = getTclWidget(tclArr[0]);
        assert(widget !is null);

        // note: timestamp missing since -command doesn't have percent substitution
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!ScalarSpinboxEvent(widget, timeMsec);
        _dispatchEvent(widget, event);
    }

    /// create and populate a list spinbox event and dispatch it.
    private static void _handleListSpinboxEvent(const Tcl_Obj*[] tclArr)
    {
        assert(tclArr.length == 4, tclArr.length.text);

        /**
            Indices:
                0  => ListSPinbox widget path

            Ignored, but implicitly passed by Tk when action equals "edit"
                1  => Name of the global traced variable
                2  => Empty
                3  => command (write or read). We only track writes.
        */

        Widget widget = getTclWidget(tclArr[0]);
        assert(widget !is null);

        // note: timestamp missing since -command doesn't have percent substitution
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!ListSpinboxEvent(widget, timeMsec);
        _dispatchEvent(widget, event);
    }

    // note: special-case. todo: use the SendEvent or PostEvent API once implemented.
    package static void _dispatchInternalEvent(Widget widget, scope Event event)
    {
        _dispatchEvent(widget, event);
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

        /** Notify events cannot block bubble events. */
        if (event.handled)
            event.handled = false;

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
        foreach (handler; widget.onSinkEvent.handlers)
        {
            handler.call(event);
            if (event.handled)
                return;
        }
    }

    /**
        Call the generic onEvent on the target widget, or an event-specific handler if
        onEvent doesn't handle the event.
    */
    private static TkEventFlag _targetEvent(Widget widget, scope Event event)
    {
        event._eventTravel = EventTravel.target;

        // call event handlers for generic onEvent
        widget.onEvent.emit(event);

        if (event.handled)
            return TkEventFlag.stop;

        assert(!event.handled);

        /** If the generic handler didn't handle it, try a specific handler. */
        switch (event.type) with (EventType)
        {
            case user:
                break;  // user events can be handled with onEvent

            case mouse:
                widget.onMouseEvent.emit(StaticCast!MouseEvent(event));
                break;

            case keyboard:
                widget.onKeyboardEvent.emit(StaticCast!KeyboardEvent(event));
                break;

            case geometry:
                widget.onGeometryEvent.emit(StaticCast!GeometryEvent(event));
                break;

            case hover:
                widget.onHoverEvent.emit(StaticCast!HoverEvent(event));
                break;

            case focus:
                widget.onFocusEvent.emit(StaticCast!FocusEvent(event));
                break;

            case destroy:
                widget._onAPIDestroyEvent.emit(StaticCast!DestroyEvent(event));
                widget.onDestroyEvent.emit(StaticCast!DestroyEvent(event));
                break;

            case drag:
                widget.onDragEvent.emit(StaticCast!DragEvent(event));
                break;

            case drop:
                widget.onDropEvent.emit(StaticCast!DropEvent(event));
                break;

            case button:
                StaticCast!Button(widget).onButtonEvent.emit(StaticCast!ButtonEvent(event));
                break;

            case check_button:
                StaticCast!CheckButton(widget).onCheckButtonEvent.emit(StaticCast!CheckButtonEvent(event));
                break;

            case menu:
                StaticCast!MenuBar(widget).onMenuEvent.emit(StaticCast!MenuEvent(event));
                break;

            case combobox:
                StaticCast!Combobox(widget).onComboboxEvent.emit(StaticCast!ComboboxEvent(event));
                break;

            case entry:
                StaticCast!Entry(widget).onEntryEvent.emit(StaticCast!EntryEvent(event));
                break;

            case validate:
                StaticCast!Entry(widget).onValidateEvent.emit(StaticCast!ValidateEvent(event));
                break;

            case listbox:
                StaticCast!Listbox(widget).onListboxEvent.emit(StaticCast!ListboxEvent(event));
                break;

            case radio_button:
                StaticCast!RadioGroup(widget).onRadioButtonEvent.emit(StaticCast!RadioButtonEvent(event));
                break;

            case slider:
                StaticCast!Slider(widget).onSliderEvent.emit(StaticCast!SliderEvent(event));
                break;

            case scalar_spinbox:
                StaticCast!ScalarSpinbox(widget).onScalarSpinboxEvent.emit(StaticCast!ScalarSpinboxEvent(event));
                break;

            case list_spinbox:
                StaticCast!ListSpinbox(widget).onListSpinboxEvent.emit(StaticCast!ListSpinboxEvent(event));
                break;

            default: assert(0, format("Unhandled event type: '%s'", event.type));
        }

        return event.handled ? TkEventFlag.stop : TkEventFlag.resume;
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
        foreach (handler; widget.onBubbleEvent.handlers)
        {
            handler.call(event);
            if (event.handled)
                return;
        }

        // if not handled, climb upwards and keep sending
        if (auto parent = widget.parentWidget)
            _bubbleEventImpl(parent, event);
    }

private:
    /** Tcl callback registration state. */
    __gshared bool _dtkCallbackInitialized;
}

/** Extract the integral X and Y points from the 2-dimensional tcl_Obj array. */
private Point getTclPoint(ref const(Tcl_Obj*)[2] tclArr)
{
    return Point(to!int(tclArr[0].tclPeekString()),
                 to!int(tclArr[1].tclPeekString()));
}

/** Extract the integral width and height from the 2-dimensional tcl_Obj array. */
private Size getTclSize(ref const(Tcl_Obj*)[2] tclArr)
{
    return Size(to!int(tclArr[0].tclPeekString()),
                to!int(tclArr[1].tclPeekString()));
}

/** Extract the mouse action from the tcl_Obj object. */
private MouseAction getTclMouseAction(const(Tcl_Obj)* tclObj)
{
    return to!MouseAction(tclObj.tclPeekString());
}

/** Extract the mouse button from the tcl_Obj object. */
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

/** Extract the key modifier from the tcl_Obj object. */
private KeyMod getTclKeyMod(const(Tcl_Obj)* tclObj)
{
    return cast(KeyMod)to!long(tclObj.tclPeekString());
}

/** Extract the mouse wheel delta from the tcl_Obj object. */
private int getTclMouseWheel(const(Tcl_Obj)* tclObj)
{
    auto wheelStr = tclObj.tclPeekString();
    return (wheelStr == "??") ? 0 : to!int(wheelStr);
}

/** Extract the key symbol from the tcl_Obj object. */
private KeySym getTclKeySym(const(Tcl_Obj)* tclObj)
{
    // note: change this to EnumBaseType after Issue 10942 is fixed for KeySym.
    alias keyBaseType = long;
    return to!KeySym(to!keyBaseType(tclObj.tclPeekString()));
}

/** Extract the unicode character from the tcl_Obj object. */
private dchar getTclUnichar(const(Tcl_Obj)* tclObj)
{
    auto input = tclObj.tclPeekString();
    return input.empty ? dchar.init : to!dchar(input.front);
}

/** Extract the Widget from the tcl_Obj object. Return null if not found. */
private Widget getTclWidget(const(Tcl_Obj)* tclObj)
{
    return Widget.lookupWidgetPath(tclObj.tclPeekString());
}

/** Extract the timestamp from the tcl_Obj object. */
private TimeMsec getTclTimestamp(const(Tcl_Obj)* tclObj)
{
    return to!TimeMsec(tclObj.tclPeekString());
}

/** Extract the keyboard action from the tcl_Obj object. */
private KeyboardAction getTclKeyboardAction(const(Tcl_Obj)* tclObj)
{
    return to!KeyboardAction(tclObj.tclPeekString());
}

/** Extract the validate action from the tcl_Obj object. */
private ValidateAction getTclValidateAction(const(Tcl_Obj)* tclObj)
{
    int input = to!int(tclObj.tclPeekString());
    switch (input) with (ValidateAction)
    {
        case  1: return insert;
        case  0: return remove;
        case -1: return revalidate;
        default: assert(0, format("Unhandled validation type: '%s'", input));
    }
}

/** Extract the validate mode from the tcl_Obj object. */
package ValidateMode getTclValidateMode(const(Tcl_Obj)* tclObj)
{
    auto input = tclObj.tclPeekString();
    switch (input) with (ValidateMode)
    {
        case "none":     return none;
        case "focus":    return focus;
        case "focusin":  return focusIn;
        case "focusout": return focusOut;
        case "key":      return key;
        case "all":      return all;
        default:         assert(0, format("Unhandled validation mode: '%s'", input));
    }
}

/** Extract the listbox action from the tcl_Obj object. */
private ListboxAction getTclListboxAction(const(Tcl_Obj)* tclObj)
{
    return to!ListboxAction(tclObj.tclPeekString());
}
