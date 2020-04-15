/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.combobox;

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

    auto box1 = new Combobox(testWindow);

    string curVal;

    size_t callCount;
    size_t expectedCallCount;

    box1.onComboboxEvent ~= (scope ComboboxEvent event)
    {
        assert(event.combobox is box1);
        assert(event.combobox.value == curVal, format("%s != %s", event.combobox.value, curVal));
        ++callCount;
    };

    assert(box1.value.empty);

    curVal = "foo bar";
    box1.value = "foo bar";
    ++expectedCallCount;
    assert(box1.value == "foo bar");

    assert(box1.values.empty);

    box1.values = ["foo", "bar", "foo bar"];
    assert(box1.values == ["foo", "bar", "foo bar"]);

    foreach (value; box1.values)
    {
        curVal = value;
        box1.value = value;
        ++expectedCallCount;
    }

    box1.readOnly = true;
    box1.readOnly = false;

    box1.pack();

    assert(callCount == expectedCallCount, text(callCount, " != ", expectedCallCount));

    app.testRun();
}
