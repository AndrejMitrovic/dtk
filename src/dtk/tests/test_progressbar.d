/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.test_progressbar;

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

    auto bar1 = new Progressbar(testWindow, Angle.horizontal, 200, ProgressMode.determinate);

    assert(bar1.maxValue > 99.0 && bar1.maxValue < 101.0);

    assert(bar1.value == 0.0);
    bar1.value = 50.0;

    auto bar2 = new Progressbar(testWindow, Angle.horizontal, 200, ProgressMode.indeterminate);

    bar2.start(20);

    bar1.pack();
    bar2.pack();

    app.testRun();  // avoid infinite running time
}
