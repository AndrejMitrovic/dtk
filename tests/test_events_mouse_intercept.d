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

    auto button = new Button(testWindow, "Flash");
    button.pack();

    auto handler = (scope ButtonEvent e)
    {
        stderr.writefln("Button event: %s", e);
        e.handled = true;
    };

    button.onButtonEvent ~= handler;

    app.run();
}

void main()
{
}
