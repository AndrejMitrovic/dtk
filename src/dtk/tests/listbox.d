/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.listbox;

version(unittest):

import dtk;
import dtk.imports;
import dtk.tests.globals;

unittest
{
    auto listbox = new Listbox(app.mainWindow);

    assert(listbox.values.empty);

    listbox.values = ["foo val", "bar"];
    assert(listbox.values == ["foo val", "bar"], listbox.values.text);

    listbox.add("doo val");
    assert(listbox.values == ["foo val", "bar", "doo val"]);

    listbox.height = 2;
    assert(listbox.height == 2);

    listbox.height = 0;

    listbox.clear();
    assert(listbox.values.empty);

    string[] values = ["foo val", "bar val", "doo", "bee", "yes", "no"];

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
