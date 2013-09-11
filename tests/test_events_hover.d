module test_events_hover;

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

    size_t callCount;
    size_t expectedCallCount;

    auto handler = (scope HoverEvent e)
    {
        assert(e.widget is button1);
        ++callCount;
    };

    button1.onHoverEvent ~= handler;
    testWindow.onHoverEvent ~= handler;
    app.mainWindow.onHoverEvent ~= handler;

    tclEvalFmt("event generate %s <Enter> -x 0 -y 0", button1.getTclName());
    ++expectedCallCount;

    assert(callCount == expectedCallCount, text(callCount, " != ", expectedCallCount));

    app.run();
}

void main()
{
}
