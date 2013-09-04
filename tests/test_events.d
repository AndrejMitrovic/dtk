module test_events;

import std.algorithm;
import std.range;
import std.stdio;
import std.traits;

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

    testWindow.onEvent = &onEvent;

    //~ auto button = new Button(testWindow, "button");

    //~ button.onFilterEvent ~= &onFilterEvent;
    //~ button.onNotifyEvent ~= &onNotifyEvent;

    //~ button.parentWidget.onSinkEvent = &onSinkEvent;
    //~ button.parentWidget.onBubbleEvent = &onBubbleEvent;

    //~ button.onEvent = &onEvent;
    //~ button.onButtonEvent = &onButtonEvent;
    //~ button.onKeyboardEvent = &onKeyboardEvent;
    //~ button.onMouseEvent = &onMouseEvent;

    //~ button.pack();

    app.run();
}

void main()
{
}
