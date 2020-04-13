module test_scrollbar;

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

    auto listbox = new Listbox(app.mainWindow);

    auto sbar = new Scrollbar(app.mainWindow, listbox, Orientation.vertical);

    app.evalFmt("grid %s -column 0 -row 0 -sticky nwes", listbox.getTclName());
    app.evalFmt("grid %s -column 1 -row 0 -sticky ns", sbar.getTclName());

    app.eval("grid [ttk::sizegrip .sz] -column 1 -row 1 -sticky se");

    app.eval("grid columnconfigure . 0 -weight 1");
    app.eval("grid rowconfigure . 0 -weight 1");

    foreach (i; 0 .. 100)
        listbox.add(format("Line %s of 100", i));

    assert(sbar.orientation == Orientation.vertical);

    sbar.orientation = Orientation.horizontal;
    assert(sbar.orientation == Orientation.horizontal);

    sbar.orientation = Orientation.vertical;

    app.run();
}

void main()
{
}
