module dtk.tests.test_listbox;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.conv;
import std.range;
import std.stdio;
import std.string;

static if (__VERSION__ < 2064)
    import dtk.all;
else
    import dtk;

import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto listbox = new Listbox(testWindow);

    assert(listbox.values.empty);

    listbox.values = ["foo", "bar"];
    assert(listbox.values == ["foo", "bar"]);

    listbox.add("doo");
    assert(listbox.values == ["foo", "bar", "doo"]);

    listbox.height = 2;
    assert(listbox.height == 2);

    listbox.height = 0;

    listbox.clear();
    assert(listbox.values.empty);

    listbox.values = ["foo", "bar", "doo", "bee", "yes", "no"];
    assert(listbox.values == ["foo", "bar", "doo", "bee", "yes", "no"]);

    assert(listbox.selectMode == SelectMode.single);

    listbox.selectMode = SelectMode.multiple;
    assert(listbox.selectMode == SelectMode.multiple);

    assert(listbox.selection.empty);

    listbox.selectRange(1, 3);
    assert(listbox.selection == [1, 2, 3]);

    listbox.selection = [0, 2, 4];
    assert(listbox.selection == [0, 2, 4]);

    listbox.selection = 1;
    assert(listbox.selection == [1]);

    listbox.clearSelection();
    assert(listbox.selection == []);

    listbox.pack();
    app.testRun();
}
