module test_spinbox;

import core.thread;

import std.conv;
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

    assert(spinbox1.value == 0.0);

    spinbox1.value = 10.0;
    assert(spinbox1.value > 9.0 && spinbox1.value < 11.0);

    assert(!spinbox1.wrap);

    spinbox1.wrap = true;
    assert(spinbox1.wrap);

    spinbox1.onEvent.connect(
    (Widget widget, Event event)
    {
        if (event.type == EventType.TkSpinboxChange)
        {
            stderr.writefln("Current scalar spinbox value: %s.", event.state);
        }
    }
    );

    auto spinbox2 = new ListSpinbox(app.mainWindow, ["foo", "bar", "doo"]);
    assert(spinbox2.values == ["foo", "bar", "doo"]);
    spinbox2.pack();

    spinbox2.wrap = true;

    spinbox2.onEvent.connect(
    (Widget widget, Event event)
    {
        if (event.type == EventType.TkSpinboxChange)
        {
            stderr.writefln("Current list spinbox value: %s.", event.state);
        }
    }
    );

    app.run();
}

void main()
{
}
