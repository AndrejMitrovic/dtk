module test_events_destroy;

import std.algorithm;
import std.range;
import std.stdio;
import std.traits;
import std.typetuple;

import dtk;

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 200, 200);

    testWindow.onDestroyEvent ~= (scope DestroyEvent e) { stderr.writeln("Destroying test window."); app.mainWindow.destroy(); };
    app.mainWindow.onDestroyEvent ~= (scope DestroyEvent e) { e.handled = true; stderr.writeln("Destroying main window."); };

    testWindow.destroy();

    app.run();
}

void main()
{
}
