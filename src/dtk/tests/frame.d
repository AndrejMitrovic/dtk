/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.frame;

version(unittest):

import dtk;
import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto frame = new Frame(testWindow);

    auto button1 = new Button(frame, "Flash");
    frame.pack();
    button1.pack();

    assert(frame.frameSize == Size(0, 0));

    frame.frameSize = Size(100, 100);
    assert(frame.frameSize == Size(100, 100));

    frame.borderWidth = 10;
    assert(frame.borderWidth == 10);

    frame.borderStyle = BorderStyle.flat;
    assert(frame.borderStyle == BorderStyle.flat);

    frame.borderStyle = BorderStyle.sunken;
    assert(frame.borderStyle == BorderStyle.sunken);

    assert(frame.padding == Padding());

    frame.padding = Padding(10);
    assert(frame.padding == Padding(10));

    frame.padding = Padding(10, 20);
    assert(frame.padding == Padding(10, 20));

    frame.padding = Padding(10, 20, 30);
    assert(frame.padding == Padding(10, 20, 30));

    frame.padding = Padding(10, 20, 30, 40);
    assert(frame.padding == Padding(10, 20, 30, 40));

    frame.padding = Padding(0, 0, 0, 10);
    assert(frame.padding == Padding(0, 0, 0, 10));

    frame.padding = Padding(0, 0, 10, 20);
    assert(frame.padding == Padding(0, 0, 10, 20));

    frame.padding = Padding(0, 10, 20, 30);
    assert(frame.padding == Padding(0, 10, 20, 30));

    frame.padding = Padding(10, 20, 30, 40);
    assert(frame.padding == Padding(10, 20, 30, 40));

    frame.padding = Padding(10, 10, 10, 10);

    app.testRun();
}

