module test_events_keyboard;

import std.algorithm;
import std.range;
import std.stdio;
import std.traits;

import dtk;

void handleEvent(scope Event event)
{
    stderr.writefln("Handle generic event: %s", event);
}

void handleKeyboardEvent(scope KeyboardEvent event)
{
    stderr.writefln("Handle keyboard event: %s", event);
}

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.onEvent = &handleEvent;
    testWindow.onKeyboardEvent = &handleKeyboardEvent;

    app.run();
}

void main()
{
}
