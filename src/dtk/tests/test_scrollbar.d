/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.test_scrollbar;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.range;
import std.stdio;
import std.string;

import dtk;

import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto listbox = new Listbox(testWindow);

    auto sbar = new Scrollbar(testWindow, listbox, Orientation.vertical);

    listbox.grid
        .setCol(0)
        .setRow(0)
        .setSticky(Sticky.nwes);

    sbar.grid
        .setCol(1)
        .setRow(0)
        .setSticky(Sticky.ns);

    app.mainWindow.grid
        .colOptions(0)
        .setWeight(1);

    app.mainWindow.grid
        .rowOptions(0)
        .setWeight(1);

    foreach (i; 0 .. 100)
        listbox.add(format("Line %s of 100", i));

    assert(sbar.orientation == Orientation.vertical);

    sbar.orientation = Orientation.horizontal;
    assert(sbar.orientation == Orientation.horizontal);

    sbar.orientation = Orientation.vertical;

    app.testRun();
}
