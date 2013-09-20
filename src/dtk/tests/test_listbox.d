/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
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

    listbox.add("doo");
    assert(listbox.values == ["foo", "bar", "doo"]);

    listbox.height = 2;
    assert(listbox.height == 2);

    listbox.height = 0;

    listbox.clear();
    assert(listbox.values.empty);

    string[] values = ["foo", "bar", "doo", "bee", "yes", "no"];

    listbox.values = values;
    assert(listbox.values == values);

    assert(listbox.selectMode == SelectMode.single);

    listbox.selectMode = SelectMode.multiple;
    assert(listbox.selectMode == SelectMode.multiple);

    assert(listbox.selection.empty);

    listbox.selectRange(1, 3);
    assert(listbox.selection == [1, 2, 3]);
    assert(listbox.selectedValues == values[1 .. 4]);

    listbox.selection = [0, 2, 4];
    assert(listbox.selection == [0, 2, 4]);
    assert(listbox.selectedValues == [values[0], values[2], values[4]]);

    listbox.selection = 1;
    assert(listbox.selection == [1]);
    assert(listbox.selectedValues.front == values[1]);

    listbox.clearSelection();
    assert(listbox.selection == []);
    assert(listbox.selectedValues.empty);

    string[] curVals;

    size_t callCount;
    size_t expectedCallCount;

    size_t[] selection;

    listbox.onListboxEvent ~= (scope ListboxEvent event)
    {
        if (event.action == ListboxAction.select)
            assert(selection == event.listbox.selection);
        else
        if (event.action == ListboxAction.edit)
            assert(values == event.listbox.values);

        ++callCount;
    };

    selection = [0, 2, 4];
    listbox.selection = selection;
    ++expectedCallCount;

    values = ["one", "two", "three", "four", "five"];
    listbox.values = values;
    ++expectedCallCount;

    listbox.pack();

    assert(callCount == expectedCallCount, text(callCount, " != ", expectedCallCount));

    app.testRun();
}
