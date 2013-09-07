module dtk.tests.test_panedwindow;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.conv;
import std.exception;
import std.range;
import std.stdio;
import std.string;

import dtk;

import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto pane = new PanedWindow(testWindow, Orientation.vertical);

    auto badButton = new Button(testWindow, "Flash");
    assertThrown(pane.add(badButton));  // cannot add a widget which isn't parented to the pane

    auto button1 = new Button(pane, "Button1");
    auto button2 = new Button(pane, "Button2");
    auto button3 = new Button(pane, "Button3");

    pane.add(button1);
    pane.add(button3, 50);
    pane.insert(button2, 1);

    assert(pane.panes.length == 3);

    pane.remove(button1);
    pane.remove(1);
    assert(pane.panes.length == 1);

    pane.remove(0);
    assert(pane.panes.length == 0);

    pane.add(button1);
    pane.add(button3);
    pane.add(button2);
    assert(pane.panes.length == 3);

    pane.setWidth(button1, 50);
    pane.setWidth(2, 50);

    pane.pack();

    app.testRun();
}
