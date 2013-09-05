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

    bool ignoreEvents;  // Tk double-click behavior workaround

    int wheel;
    MouseAction action;
    MouseButton button;
    KeyMod keyMod;
    Point widgetMousePos;

    // we only want to test this when we explicitly generate move events,
    // since the mouse can be at an arbitrary point when generating non-move events.
    enum MotionTest { none, widget, desktop }
    MotionTest motionTest;
    Point desktopMousePos;

    auto handler = (scope MouseEvent e)
    {
        if (ignoreEvents)
            return;

        assert(e.action == action, text(action, " ", e.action));
        assert(e.button == button, text(button, " ", e.button));
        assert(e.wheel  == wheel,  text(wheel,  " ", e.wheel));
        assert(e.keyMod == keyMod, text(keyMod, " ", e.keyMod));

        switch (motionTest)
        {
            case MotionTest.widget:
                assert(e.widgetMousePos == widgetMousePos, text(widgetMousePos, " ", e.widgetMousePos));
                break;

            case MotionTest.desktop:
                assert(e.desktopMousePos == desktopMousePos, text(desktopMousePos, " ", e.desktopMousePos));
                break;

            default:
        }
    };

    testWindow.onMouseEvent = handler;

    static mouseButtons = [MouseButton.button1, MouseButton.button2, MouseButton.button3, MouseButton.button4, MouseButton.button5];

    alias keyMods = NoDuplicates!(EnumMembers!KeyMod);

    enum buttonCount = 5;

    // Note: Two same-button press events will generate a double-click event, even if there was a
    // button release event in-between. To work around this, we can inject another button-press
    // after the release one, but with a different button.
    // When button 1 is tested, we generate a button 5 event (not a button 2 event), since generating a
    // button 2 event would link to the next loop when button 2 is tested.
    // Note that the release event has to be generated as well, otherwise the state flag will have the
    // key as a modifier.
    void genIgnoredEvent(size_t buttonIdx)
    {
        ignoreEvents = true;
        tclEvalFmt("event generate %s <ButtonPress> -button %s", testWindow.getTclName(), ((buttonIdx - 2) % mouseButtons.length));
        tclEvalFmt("event generate %s <ButtonRelease> -button %s", testWindow.getTclName(), ((buttonIdx - 2) % mouseButtons.length));
        ignoreEvents = false;
    }

    // test press and release
    foreach (idx, newButton; mouseButtons)
    {
        button = newButton;
        keyMod = KeyMod.none;

        static immutable modifiers = ["", "Double-", "Triple-", "Quadruple-"];
        static immutable mouseActions = [MouseAction.click, MouseAction.double_click, MouseAction.triple_click, MouseAction.quadruple_click];

        // test single, double click, etc.
        foreach (modifier, mouseAction; zip(modifiers, mouseActions))
        {
            action = mouseAction;
            tclEvalFmt("event generate %s <%sButtonPress> -button %s", testWindow.getTclName(), modifier, idx + 1);

            action = MouseAction.release;
            tclEvalFmt("event generate %s <ButtonRelease> -button %s", testWindow.getTclName(), idx + 1);

            genIgnoredEvent(idx);
        }

        // test with key modifiers
        foreach (newKeyMod; keyMods)
        {
            keyMod = newKeyMod;

            action = MouseAction.press;
            tclEvalFmt("event generate %s <ButtonPress> -button %s -state %s",
                       testWindow.getTclName(), idx + 1, cast(int)newKeyMod);

            action = MouseAction.release;
            tclEvalFmt("event generate %s <ButtonRelease> -button %s -state %s",
                       testWindow.getTclName(), idx + 1, cast(int)newKeyMod);

            genIgnoredEvent(idx);
        }
    }

    // test mouse wheel
    foreach (sign; -1 .. 2)
    {
        // only MouseWheel supports delta, but doesn't support button option
        action = MouseAction.wheel;
        button = MouseButton.none;

        // test with key modifiers
        foreach (newKeyMod; keyMods)
        {
            keyMod = newKeyMod;
            wheel = sign * 120;
            tclEvalFmt("event generate %s <MouseWheel> -delta %s -state %s",
                       testWindow.getTclName(), wheel, cast(int)newKeyMod);
        }
    }

    action = MouseAction.motion;
    button = MouseButton.none;
    keyMod = KeyMod.none;
    wheel = 0;

    // test mouse move
    foreach (x; 0 .. 5)
    foreach (y; 5 .. 10)
    {
        motionTest = MotionTest.widget;
        widgetMousePos = Point(x, y);
        tclEvalFmt("event generate %s <Motion> -x %s -y %s",
                    testWindow.getTclName(), widgetMousePos.x, widgetMousePos.y);

        motionTest = MotionTest.desktop;
        desktopMousePos = Point(x, y);
        tclEvalFmt("event generate %s <Motion> -X %s -Y %s",
                    testWindow.getTclName(), desktopMousePos.x, desktopMousePos.y);
    }

    app.run();
}

void main()
{
}
