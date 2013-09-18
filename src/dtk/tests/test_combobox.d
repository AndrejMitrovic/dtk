module dtk.tests.test_combobox;

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

    curVal = "foobar";
    box1.value = "foobar";
    ++expectedCallCount;
    assert(box1.value == "foobar");

    assert(box1.values.empty);
    box1.values = ["foo", "bar", "foobar"];

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
