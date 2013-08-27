module dtk.tests.test_labelframe;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.conv;
import std.range;
import std.stdio;
import std.string;

static if (__VERSION__ < 2064)
    import dtk.all;
else
    import dtk;

import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto frame = new LabelFrame(testWindow);

    assert(frame.underline == -1);
    frame.underline = 2;
    assert(frame.underline == 2);

    auto button1 = new Button(frame, "Flash");
    assert(button1.parentWidget is frame);

    frame.text = "My frame";
    assert(frame.text == "My frame");

    frame.anchor = Anchor.north;
    assert(frame.anchor == Anchor.north, frame.anchor.text);

    assert(frame.size == Size(0, 0));

    frame.size = Size(100, 100);
    assert(frame.size == Size(100, 100));

    frame.borderWidth = 10;
    assert(frame.borderWidth == 10);

    frame.borderStyle = BorderStyle.flat;
    assert(frame.borderStyle == BorderStyle.flat);

    frame.borderStyle = BorderStyle.groove;
    assert(frame.borderStyle == BorderStyle.groove);

    frame.padding = Padding(10);
    assert(frame.padding == Padding(10));

    frame.padding = Padding(10, 20, 30, 40);
    assert(frame.padding == Padding(10, 20, 30, 40));

    frame.padding = Padding(10, 10, 10, 10);

    frame.pack();
    button1.pack();

    app.testRun();
}

