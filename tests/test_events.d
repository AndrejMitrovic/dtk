module test_events;

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

void onButtonEvent(scope ButtonEvent event)
{
    stderr.writefln("Handle button event: %s", event);
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

    auto button = new Button(testWindow, "button");

    button.onFilterEvent ~= &onFilterEvent;
    button.onNotifyEvent ~= &onNotifyEvent;

    button.parentWidget.onSinkEvent = &onSinkEvent;
    button.parentWidget.onBubbleEvent = &onBubbleEvent;

    button.onEvent = &onEvent;
    button.onButtonEvent = &onButtonEvent;

    button.pack();

    app.run();
}

void main()
{
}
