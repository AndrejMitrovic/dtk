module test_events_focus;

import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import std.traits;
import std.typetuple;

import dtk;

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 200, 200);

    auto frame = new Frame(testWindow);
    frame.pack();

    auto button1 = new Button(frame, "Button 1");
    button1.grid.setRow(0).setCol(0);

    auto button2 = new Button(frame, "Button 2");
    button2.grid.setRow(0).setCol(1);

    FocusAction action;
    Widget widget;

    size_t callCount;
    size_t expectedCallCount;

    testWindow.onSinkEvent ~= (scope Event ev)
    {
        if (ev.type != EventType.focus)
            return;

        auto event = cast(FocusEvent)ev;
        assert(event.action == action, text(event.action, " != ", action));
        assert(event.widget == widget, text(event.widget, " != ", widget));
        callCount++;
    };

    action = FocusAction.focus;
    widget = button1;
    tclEvalFmt("event generate %s <FocusIn>", button1.getTclName());
    ++expectedCallCount;

    action = FocusAction.unfocus;
    widget = button1;
    tclEvalFmt("event generate %s <FocusOut>", button1.getTclName());
    ++expectedCallCount;

    action = FocusAction.focus;
    widget = button1;
    tclEvalFmt("event generate %s <FocusIn>", button1.getTclName());
    ++expectedCallCount;

    action = FocusAction.focus;
    widget = button1;
    tclEvalFmt("event generate %s <KeyPress> -keysym %s", button1.getTclName(), cast(int)KeySym.Tab);
    tclEvalFmt("event generate %s <KeyRelease> -keysym %s", button1.getTclName(), cast(int)KeySym.Tab);
    ++expectedCallCount;

    assert(callCount == expectedCallCount, text(callCount, " != ", expectedCallCount));

    app.run();
}

void main()
{
}
