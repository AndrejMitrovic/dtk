module dtk.tests.test_events_destroy;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import std.traits;
import std.typetuple;

import dtk;

import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);

    bool handled;
    testWindow.onDestroyEvent ~= (scope DestroyEvent e) { handled = true; };
    testWindow.destroy();
    assert(handled);

    app.testRun();
}
