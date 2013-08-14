module dtk.tests.test_sizegrip;

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
    app.mainWindow.disableSizegrip();
    app.mainWindow.enableSizegrip();
    app.testRun();
}
