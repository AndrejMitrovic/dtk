module dtk.tests.test_separator;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk;
import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto button1 = new Button(testWindow, "button1");
    auto button2 = new Button(testWindow, "button2");

    auto separator1 = new Separator(testWindow, Orientation.horizontal);
    assert(separator1.orientation == Orientation.horizontal);

    app.evalFmt("grid %s -column 0 -row 0 -sticky nsew -padx 5 -pady 5", button1.getTclName());
    app.evalFmt("grid %s -column 0 -row 1 -sticky nsew", separator1.getTclName());
    app.evalFmt("grid %s -column 0 -row 2 -sticky nsew -padx 5 -pady 5", button2.getTclName());

    auto button3 = new Button(testWindow, "button3");
    auto button4 = new Button(testWindow, "button4");

    auto separator2 = new Separator(testWindow, Orientation.vertical);
    assert(separator2.orientation == Orientation.vertical);

    app.evalFmt("grid %s -column 0 -row 3 -sticky nsew -padx 5 -pady 5", button3.getTclName());
    app.evalFmt("grid %s -column 1 -row 3 -sticky nsew", separator2.getTclName());
    app.evalFmt("grid %s -column 2 -row 3 -sticky nsew -padx 5 -pady 5", button4.getTclName());

    app.testRun();
}
