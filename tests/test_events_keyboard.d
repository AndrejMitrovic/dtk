module test_events_keyboard;

import std.algorithm;
import std.range;
import std.stdio;
import std.traits;

import dtk;

void onFilterEvent(scope Event event)
{
    stderr.writefln("Handle filtered event: %s", event);
    //~ event.handled = true;
}

void onSinkEvent(scope Event event)
{
    stderr.writefln("Handle sink event: %s", event);
    //~ event.handled = true;
}

void onEvent(scope Event event)
{
    stderr.writefln("Handle generic event: %s", event);
    //~ event.handled = true;
}

void onKeyboardEvent(scope KeyboardEvent event)
{
    stderr.writefln("Handle keyboard event: %s", event);
    //~ event.handled = true;
}

void onNotifyEvent(scope Event event)
{
    stderr.writefln("Handle notify event: %s", event);
    //~ event.handled = true;
}

void onBubbleEvent(scope Event event)
{
    stderr.writefln("Handle bubble event: %s", event);
    //~ event.handled = true;
}

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 200, 200);

    testWindow.onFilterEvent.connect(&onFilterEvent);
    testWindow.onNotifyEvent.connect(&onNotifyEvent);

    testWindow.parentWindow.onSinkEvent = &onSinkEvent;
    testWindow.parentWindow.onBubbleEvent = &onBubbleEvent;

    testWindow.onEvent = &onEvent;
    testWindow.onKeyboardEvent = &onKeyboardEvent;

    app.run();
}

void main()
{
}
