module test_cursor;

import core.thread;

import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk;

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto label = new Label(testWindow);
    label.grid.setRow(0).setCol(0).setColSpan(2);
    label.text = "Some other cursor";

    assert(app.mainWindow.cursor == Cursor.inherited);
    assert(label.cursor == Cursor.inherited);

    label.cursor = Cursor.watch;
    assert(label.cursor == Cursor.watch);

    label.cursor = Cursor.inherited;
    assert(label.cursor == Cursor.inherited);

    app.run();
}

void main()
{
}
