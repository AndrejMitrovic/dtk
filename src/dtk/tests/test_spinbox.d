/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.test_spinbox;

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

    auto spinbox1 = new ScalarSpinbox(testWindow);
    spinbox1.pack();

    assert(spinbox1.value == 0.0);

    spinbox1.value = 10.0;
    assert(spinbox1.value > 9.0 && spinbox1.value < 11.0);

    assert(!spinbox1.wrap);

    spinbox1.wrap = true;
    assert(spinbox1.wrap);

    //~ spinbox1.onEvent.connect(
        //~ (Widget widget, Event event)
        //~ {
            //~ if (event.type == EventType.TkSpinboxChange)
            //~ {
                //~ logf("Current scalar spinbox value: %s.", event.state);
            //~ }
        //~ }
    //~ );

    auto spinbox2 = new ListSpinbox(app.mainWindow, ["foo", "bar", "doo"]);
    assert(spinbox2.values == ["foo", "bar", "doo"]);
    spinbox2.pack();

    spinbox2.wrap = true;

    //~ spinbox2.onEvent.connect(
        //~ (Widget widget, Event event)
        //~ {
            //~ if (event.type == EventType.TkSpinboxChange)
            //~ {
                //~ logf("Current list spinbox value: %s.", event.state);
            //~ }
        //~ }
    //~ );

    app.testRun();
}
