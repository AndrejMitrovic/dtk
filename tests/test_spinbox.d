module test_spinbox;

import core.thread;

import std.conv;
import std.math;
import std.range;
import std.stdio;
import std.string;

import dtk;
import dtk.tests.globals;

unittest
{
    auto app = new App;

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

    auto spinbox2 = new ListSpinbox(app.mainWindow, ["foo", "bar", "doo"]);
    assert(spinbox2.values == ["foo", "bar", "doo"]);
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

    app.run();
}

void main()
{
}
