module test_sizegrip;

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
    app.mainWindow.disableSizegrip();
    app.mainWindow.enableSizegrip();
    app.run();
}

void main()
{
}
