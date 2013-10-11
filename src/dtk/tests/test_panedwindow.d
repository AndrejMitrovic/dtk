/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
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

    auto pane = new PanedWindow(testWindow, Angle.vertical);

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

    pane.setWeight(button1, 50);
    assert(pane.getWeight(button1) == 50);

    pane.setWeight(2, 50);
    assert(pane.getWeight(2) == 50);

    pane.pack();

    app.testRun();
}
