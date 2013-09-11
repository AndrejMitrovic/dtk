module dtk.tests.test_events_hover;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.algorithm;
import std.range;
import std.stdio;
import std.traits;
import std.typetuple;

import dtk;

import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);

    auto frame = new Frame(testWindow);

    auto button1 = new Button(frame, "Flash");
    frame.pack();
    button1.pack();

    HoverAction action;

    size_t callCount;
    size_t expectedCallCount;

    auto handler = (scope HoverEvent e)
    {
        assert(e.widget is button1);
        assert(e.action == action);
        ++callCount;
    };

    button1.onHoverEvent ~= handler;

    action = HoverAction.enter;
    tclEvalFmt("event generate %s <Enter> -x 0 -y 0", button1.getTclName());
    ++expectedCallCount;

    action = HoverAction.leave;
    tclEvalFmt("event generate %s <Leave> -x 200 -y 200", button1.getTclName());
    ++expectedCallCount;

    assert(callCount == expectedCallCount, text(callCount, " != ", expectedCallCount));

    app.testRun();
}
