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

    tclEvalFmt("grid %s -column 0 -row 0 -sticky nwes", listbox.getTclName());
    tclEvalFmt("grid %s -column 1 -row 0 -sticky ns", sbar.getTclName());
    tclEvalFmt("grid columnconfigure . 0 -weight 1");
    tclEvalFmt("grid rowconfigure . 0 -weight 1");

    foreach (i; 0 .. 100)
        listbox.add(format("Line %s of 100", i));

    assert(sbar.orientation == Orientation.vertical);

    sbar.orientation = Orientation.horizontal;
    assert(sbar.orientation == Orientation.horizontal);

    sbar.orientation = Orientation.vertical;

    app.testRun();
}
