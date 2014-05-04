module test_command;

import core.thread;

import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk;
import dtk.tests.globals;

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto button = new Button(testWindow, "Button");
    button.pack();

    button.onKeyboardEvent ~= (scope KeyboardEvent event)
    {
        stderr.writefln("Key event: %s", event);
    };

    //~ auto button2 = new Button(testWindow, "Button2");
    //~ button2.pack();

    button.focus();
    button.busy.hold();

    //~ button2.focus();

    app.run();
}

void main()
{
}
