module test_events;

import std.algorithm;
import std.range;
import std.stdio;
import std.traits;
import std.typetuple;

import dtk;

void onFilterEvent(scope Event event)
{
    //~ stderr.writefln("Handle filtered event: %s", event);
    assert(event.eventTravel == EventTravel.filter);
    //~ event.handled = true;
}

void onSinkEvent(scope Event event)
{
    //~ stderr.writefln("Handle sink event: %s", event);
    assert(event.eventTravel == EventTravel.sink);
    //~ event.handled = true;
}

void onEvent(scope Event event)
{
    stderr.writefln("Handle generic event: %s", event);
    assert(event.eventTravel == EventTravel.target);
    //~ event.handled = true;
}

void onMouseEvent(scope MouseEvent event)
{
    //~ stderr.writefln("Handle mouse event: %s", event);
    assert(event.eventTravel == EventTravel.target);

    // if set, button should not be pushed.
    //~ event.handled = true;
}

void onKeyboardEvent(scope KeyboardEvent event)
{
    //~ stderr.writefln("Handle keyboard  event: %s", event);
    assert(event.eventTravel == EventTravel.target);
    //~ event.handled = true;
}

void onButtonEvent(scope ButtonEvent event)
{
    //~ stderr.writefln("Handle button event: %s", event);
    assert(event.eventTravel == EventTravel.target);
    //~ event.handled = true;
}

void onNotifyEvent(scope Event event)
{
    //~ stderr.writefln("Handle notify event: %s", event);
    assert(event.eventTravel == EventTravel.notify);
    //~ event.handled = true;
}

void onBubbleEvent(scope Event event)
{
    //~ stderr.writefln("Handle bubble event: %s", event);
    assert(event.eventTravel == EventTravel.bubble);
    //~ event.handled = true;
}

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 200, 200);

    /** Test mouse */

    int wheel;
    MouseAction action;
    MouseButton button;
    KeyMod keyMod;

    testWindow.onMouseEvent = (scope MouseEvent e)
    {
        assert(e.action == action, text(action, " ", e.action));
        assert(e.button == button, text(button, " ", e.button));
        assert(e.wheel  == wheel,  text(wheel,  " ", e.wheel));
        assert(e.keyMod == keyMod, text(keyMod, " ", e.keyMod));
    };

    static mouseButtons = [MouseButton.button1, MouseButton.button2, MouseButton.button3, MouseButton.button4, MouseButton.button5];

    alias keyMods = NoDuplicates!(EnumMembers!KeyMod);

    foreach (idx, newButton; mouseButtons)
    {
        button = newButton;

        action = MouseAction.press;
        tclEvalFmt("event generate %s <ButtonPress> -button %s", testWindow.getTclName(), idx + 1);

        action = MouseAction.release;
        tclEvalFmt("event generate %s <ButtonRelease> -button %s", testWindow.getTclName(), idx + 1);

        // note: if we issue two press events too quickly it will generate a double-click event
        //~ tclEval("after 50");

        //~ foreach (newKeyMod; keyMods)
        //~ {
            //~ keyMod = newKeyMod;

            //~ action = MouseAction.press;
            //~ tclEvalFmt("event generate %s <ButtonPress> -button %s -state %s",
                       //~ testWindow.getTclName(), idx + 1, cast(int)newKeyMod);

            //~ action = MouseAction.release;
            //~ tclEvalFmt("event generate %s <ButtonRelease> -button %s -state %s",
                       //~ testWindow.getTclName(), idx + 1, cast(int)newKeyMod);
        //~ }
    }

    //~ foreach (sign; -1 .. 2)
    //~ {
        //~ // only MouseWheel supports delta, but doesn't support button option
        //~ action = MouseAction.wheel;
        //~ foreach (newKeyMod; keyMods)
        //~ {
            //~ keyMod = newKeyMod;
            //~ wheel = sign * 120;
            //~ tclEvalFmt("event generate %s <MouseWheel> -delta %s -state %s",
                       //~ testWindow.getTclName(), wheel, cast(int)newKeyMod);
        //~ }
    //~ }

    //~ tclEvalFmt("bind dtk::intercept_tag <KeyRelease> { dtk::callback_handler keyboard release %N %A %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <ButtonPress-1> { dtk::callback_handler mouse press button1 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Double-ButtonPress-1> { dtk::callback_handler mouse release button1 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Triple-ButtonPress-1> { dtk::callback_handler mouse triple_click button1 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Quadruple-ButtonPress-1> { dtk::callback_handler mouse quadruple_click button1 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <ButtonRelease-1> { dtk::callback_handler mouse release button1 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <ButtonPress-2> { dtk::callback_handler mouse press button2 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Double-ButtonPress-2> { dtk::callback_handler mouse release button2 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Triple-ButtonPress-2> { dtk::callback_handler mouse triple_click button2 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Quadruple-ButtonPress-2> { dtk::callback_handler mouse quadruple_click button2 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <ButtonRelease-2> { dtk::callback_handler mouse release button2 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <ButtonPress-3> { dtk::callback_handler mouse press button3 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Double-ButtonPress-3> { dtk::callback_handler mouse release button3 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Triple-ButtonPress-3> { dtk::callback_handler mouse triple_click button3 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Quadruple-ButtonPress-3> { dtk::callback_handler mouse quadruple_click button3 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <ButtonRelease-3> { dtk::callback_handler mouse release button3 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <ButtonPress-4> { dtk::callback_handler mouse press button4 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Double-ButtonPress-4> { dtk::callback_handler mouse release button4 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Triple-ButtonPress-4> { dtk::callback_handler mouse triple_click button4 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Quadruple-ButtonPress-4> { dtk::callback_handler mouse quadruple_click button4 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <ButtonRelease-4> { dtk::callback_handler mouse release button4 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <ButtonPress-5> { dtk::callback_handler mouse press button5 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Double-ButtonPress-5> { dtk::callback_handler mouse release button5 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Triple-ButtonPress-5> { dtk::callback_handler mouse triple_click button5 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Quadruple-ButtonPress-5> { dtk::callback_handler mouse quadruple_click button5 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <ButtonRelease-5> { dtk::callback_handler mouse release button5 %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <Motion> { dtk::callback_handler mouse motion %b %D %s %W %x %y %X %Y %t } -- result:
    //~ tclEvalFmt("bind dtk::intercept_tag <MouseWheel> { dtk::callback_handler mouse wheel %b %D %s %W %x %y %X %Y %t } -- result:

    //~ tclEvalFmt("event generate %s "

    app.run();
}

void main()
{
}
