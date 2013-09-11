module test_events_focus;

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

    auto frame = new Frame(testWindow);

    auto button1 = new Button(frame, "Flash");
    frame.pack();
    button1.pack();

    FocusAction action;

    size_t callCount;
    size_t expectedCallCount;

    auto handler = (scope FocusEvent e)
    {
        assert(e.widget is button1);
        assert(e.action == action);
        ++callCount;
    };

    button1.onFocusEvent ~= handler;

    action = FocusAction.enter;
    tclEvalFmt("event generate %s <FocusIn>", button1.getTclName());
    ++expectedCallCount;

    action = FocusAction.leave;
    tclEvalFmt("event generate %s <FocusOut>", button1.getTclName());
    ++expectedCallCount;

    assert(callCount == expectedCallCount, text(callCount, " != ", expectedCallCount));

    app.run();
}

void main()
{
}
