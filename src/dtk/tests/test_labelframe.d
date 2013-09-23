/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.test_labelframe;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk;

import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    LabelFrame frame = new LabelFrame(testWindow);

    assert(frame.underline == -1);
    frame.underline = 2;
    assert(frame.underline == 2);

    auto button1 = new Button(frame, "Flash");
    assert(button1.parentWidget is frame);

    frame.text = "My frame";
    assert(frame.text == "My frame");

    frame.anchor = Anchor.north;
    assert(frame.anchor == Anchor.north, frame.anchor.text);

    assert(frame.frameSize == Size(0, 0));

    frame.frameSize = Size(100, 100);
    assert(frame.frameSize == Size(100, 100));

    frame.borderWidth = 10;
    assert(frame.borderWidth == 10);

    frame.borderStyle = BorderStyle.flat;
    assert(frame.borderStyle == BorderStyle.flat);

    frame.borderStyle = BorderStyle.groove;
    assert(frame.borderStyle == BorderStyle.groove);

    frame.padding = Padding(10);
    assert(frame.padding == Padding(10));

    frame.padding = Padding(10, 20, 30, 40);
    assert(frame.padding == Padding(10, 20, 30, 40));

    frame.padding = Padding(10, 10, 10, 10);

    assert(frame.textWidth == 100);  // seems to be 100 initially, just like label
    frame.textWidth = -50;  // set minimum 50 units
    assert(frame.textWidth == -50);

    frame.textWidth = 0;
    assert(frame.textWidth == 0);

    frame.textWidth = 50;   // set maximum 50 units
    assert(frame.textWidth == 50);

    frame.pack();
    button1.pack();

    app.testRun();
}

