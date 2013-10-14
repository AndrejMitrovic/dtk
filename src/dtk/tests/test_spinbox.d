/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.test_spinbox;

version(unittest):
version(DTK_UNITTEST):

import dtk;
import dtk.imports;
import dtk.utils;
import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto spinbox1 = new ScalarSpinbox(app.mainWindow);
    spinbox1.pack();

    assert(spinbox1.value.isNaN, spinbox1.value.text);

    spinbox1.value = 10.0;
    assert(spinbox1.value > 9.0 && spinbox1.value < 11.0);

    assert(!spinbox1.wrap);

    spinbox1.wrap = true;
    assert(spinbox1.wrap);

    size_t callCount;
    size_t expectedCallCount;

    float value = 0;

    spinbox1.onScalarSpinboxEvent ~= (scope ScalarSpinboxEvent event)
    {
        assert(event.scalarSpinbox.value > value - 1 && event.scalarSpinbox.value < value + 1);
        ++callCount;
    };

    value = 1;
    spinbox1.value = 1;
    ++expectedCallCount;

    auto spinbox2 = new ListSpinbox(app.mainWindow, ["foo val", "bar val", "doo val"]);
    assert(spinbox2.values == ["foo val", "bar val", "doo val"], spinbox2.values.text);
    spinbox2.pack();

    spinbox2.wrap = true;

    string item;

    spinbox2.onListSpinboxEvent ~= (scope ListSpinboxEvent event)
    {
        assert(event.listSpinbox.value == item);
        ++callCount;
    };

    item = spinbox2.values.front;
    spinbox2.value = item;
    ++expectedCallCount;

    assert(callCount == expectedCallCount, format("%s != %s", callCount, expectedCallCount));

    app.testRun();
}
