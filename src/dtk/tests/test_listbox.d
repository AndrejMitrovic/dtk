module dtk.tests.test_listbox;

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
    auto listbox = new Listbox(app.mainWindow);

    assert(listbox.values.empty);

    listbox.values = ["foo", "bar"];
    assert(listbox.values == ["foo", "bar"]);

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
