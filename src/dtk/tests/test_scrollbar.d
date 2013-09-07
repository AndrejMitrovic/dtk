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

    app.evalFmt("grid %s -column 0 -row 0 -sticky nwes", listbox.getTclName());
    app.evalFmt("grid %s -column 1 -row 0 -sticky ns", sbar.getTclName());
    app.eval("grid columnconfigure . 0 -weight 1");
    app.eval("grid rowconfigure . 0 -weight 1");

    foreach (i; 0 .. 100)
        listbox.add(format("Line %s of 100", i));

    assert(sbar.orientation == Orientation.vertical);

    sbar.orientation = Orientation.horizontal;
    assert(sbar.orientation == Orientation.horizontal);

    sbar.orientation = Orientation.vertical;

    app.testRun();
}
