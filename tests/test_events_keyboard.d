module test_events_keyboard;

import std.algorithm;
import std.range;
import std.stdio;
import std.traits;

import dtk;

void onFilterEvent(scope Event event)
{
    stderr.writefln("Handle filtered event: %s", event);
    assert(event.eventTravel == EventTravel.filter);
    //~ event.handled = true;
}

void onSinkEvent(scope Event event)
{
    stderr.writefln("Handle sink event: %s", event);
    assert(event.eventTravel == EventTravel.sink);
    //~ event.handled = true;
}

void onEvent(scope Event event)
{
    stderr.writefln("Handle generic event: %s", event);
    assert(event.eventTravel == EventTravel.target);
    //~ event.handled = true;
}

void onKeyboardEvent(scope KeyboardEvent event)
{
    stderr.writefln("Handle keyboard event: %s", event);
    assert(event.eventTravel == EventTravel.target);
    //~ event.handled = true;
}

void onNotifyEvent(scope Event event)
{
    stderr.writefln("Handle notify event: %s", event);
    assert(event.eventTravel == EventTravel.notify);
    //~ event.handled = true;
}

void onBubbleEvent(scope Event event)
{
    stderr.writefln("Handle bubble event: %s", event);
    assert(event.eventTravel == EventTravel.bubble);
    //~ event.handled = true;
}

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 200, 200);

    testWindow.onFilterEvent ~= &onFilterEvent;
    testWindow.onNotifyEvent ~= &onNotifyEvent;

    testWindow.parentWidget.onSinkEvent = &onSinkEvent;
    testWindow.parentWidget.onBubbleEvent = &onBubbleEvent;

    testWindow.onEvent = &onEvent;
    testWindow.onKeyboardEvent = &onKeyboardEvent;

    app.run();
}

void main()
{
}
