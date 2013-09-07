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
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    testWindow.disableSizegrip();
    testWindow.enableSizegrip();
    app.testRun();
}
