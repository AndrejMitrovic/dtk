module test_events_mouse;

import std.algorithm;
import std.range;
import std.stdio;
import std.traits;
import std.typetuple;

import dtk;

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 200, 200);

    // Tk double-click behavior workaround
    bool ignoreEvents;

    int wheel;
    MouseAction action;
    MouseButton button;
    KeyMod keyMod;

    // we only want to test this when we explicitly generate move events,
    // since the mouse can be at an arbitrary point when generating non-move events.
    bool motionTest;
    Point widgetMousePos;

    size_t callCount;
    size_t expectedCallCount;

    auto handler = (scope MouseEvent e)
    {
        if (ignoreEvents)
            return;

        assert(e.action == action, text(action, " != ", e.action));
        assert(e.button == button, text(button, " != ", e.button));
        assert(e.wheel  == wheel,  text(wheel,  " != ", e.wheel));
        assert(e.keyMod == keyMod, text(keyMod, " != ", e.keyMod));
        if (motionTest) assert(e.widgetMousePos == widgetMousePos, text(widgetMousePos, " ", e.widgetMousePos));
        ++callCount;
    };

    testWindow.onMouseEvent ~= handler;

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

        /** test single click. */
        action = MouseAction.press;
        tclEvalFmt("event generate %s <ButtonPress> -button %s", testWindow.getTclName(), idx + 1);
        ++expectedCallCount;

        action = MouseAction.release;
        tclEvalFmt("event generate %s <ButtonRelease> -button %s", testWindow.getTclName(), idx + 1);
        ++expectedCallCount;
        genIgnoredEvent(idx);

        // todo note: can't directly call double/triple-ButtonPress.
        // workaround follows after this section.
        /+
        static immutable modifiers = ["", "Double-", "Triple-", "Quadruple-"];
        static immutable mouseActions = [MouseAction.click, MouseAction.double_click, MouseAction.triple_click, MouseAction.quadruple_click];

        // test single, double click, etc.
        foreach (modifier, mouseAction; zip(modifiers, mouseActions))
        {
            action = mouseAction;
            tclEvalFmt("event generate %s <%sButtonPress> -button %s", testWindow.getTclName(), modifier, idx + 1);
            ++expectedCallCount;

            action = MouseAction.release;
            tclEvalFmt("event generate %s <ButtonRelease> -button %s", testWindow.getTclName(), idx + 1);
            ++expectedCallCount;

            genIgnoredEvent(idx);
        } +/

        void testMultiClick(size_t count, MouseAction mouseAction)
        {
            ignoreEvents = true;
            foreach (i; 1 .. count)
            {
                tclEvalFmt("event generate %s <ButtonPress> -button %s", testWindow.getTclName(), idx + 1);
                tclEvalFmt("event generate %s <ButtonRelease> -button %s", testWindow.getTclName(), idx + 1);
            }
            ignoreEvents = false;

            action = mouseAction;
            tclEvalFmt("event generate %s <ButtonPress> -button %s", testWindow.getTclName(), idx + 1);
            ++expectedCallCount;

            action = MouseAction.release;
            tclEvalFmt("event generate %s <ButtonRelease> -button %s", testWindow.getTclName(), idx + 1);
            ++expectedCallCount;
            genIgnoredEvent(idx);
        }

        testMultiClick(2, MouseAction.double_click);
        testMultiClick(3, MouseAction.triple_click);
        testMultiClick(4, MouseAction.quadruple_click);

        // test with key modifiers
        foreach (newKeyMod; keyMods)
        {
            keyMod = newKeyMod;

            action = MouseAction.press;
            tclEvalFmt("event generate %s <ButtonPress> -button %s -state %s",
                       testWindow.getTclName(), idx + 1, cast(int)newKeyMod);
            ++expectedCallCount;

            action = MouseAction.release;
            tclEvalFmt("event generate %s <ButtonRelease> -button %s -state %s",
                       testWindow.getTclName(), idx + 1, cast(int)newKeyMod);
            ++expectedCallCount;

            genIgnoredEvent(idx);
        }
    }

    static mouseKeyMods = [KeyMod.mouse_button1, KeyMod.mouse_button2, KeyMod.mouse_button3, KeyMod.mouse_button4, KeyMod.mouse_button5];

    assert(mouseKeyMods.length == mouseButtons.length);

    // test multiple mouse button presses
    foreach (idx, newButton; mouseButtons)
    {
        // modifier button: press and hold
        action = MouseAction.press;
        button = newButton;
        keyMod = KeyMod.none;
        tclEvalFmt("event generate %s <ButtonPress> -button %s", testWindow.getTclName(), idx + 1);
        ++expectedCallCount;

        // last key becomes the modifier
        action = MouseAction.press;
        button = mouseButtons[(idx + 1) % mouseButtons.length];  // new button
        keyMod = mouseKeyMods[idx];
        tclEvalFmt("event generate %s <ButtonPress> -button %s", testWindow.getTclName(),   ((idx + 1) % mouseButtons.length) + 1);
        ++expectedCallCount;

        action = MouseAction.release;
        tclEvalFmt("event generate %s <ButtonRelease> -button %s", testWindow.getTclName(), ((idx + 1) % mouseButtons.length) + 1);
        ++expectedCallCount;

        // modifier button: release
        action = MouseAction.release;
        button = newButton;
        keyMod = KeyMod.none;
        tclEvalFmt("event generate %s <ButtonRelease> -button %s", testWindow.getTclName(), idx + 1);
        ++expectedCallCount;

        genIgnoredEvent(idx);
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
            ++expectedCallCount;
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
        motionTest = true;
        widgetMousePos = Point(x, y);
        tclEvalFmt("event generate %s <Motion> -x %s -y %s",
                    testWindow.getTclName(), widgetMousePos.x, widgetMousePos.y);
        ++expectedCallCount;
    }

    assert(callCount == expectedCallCount, text(callCount, " != ", expectedCallCount));

    app.run();
}

void main()
{
}
