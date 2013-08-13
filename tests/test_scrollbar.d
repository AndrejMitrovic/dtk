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
    auto sbar = new Scrollbar(app.mainWindow);

    sbar.pack();
    app.run();
}

void main()
{
}
