module dtk.tests.test_frame;

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
    auto frame = new Frame(mainWindow);

    auto button1 = new Button(frame, "Flash");
    frame.pack();
    button1.pack();

    assert(frame.size == Size(0, 0));

    frame.size = Size(100, 100);
    log(frame.size);
    assert(frame.size == Size(100, 100));

    frame.borderWidth = 10;
    assert(frame.borderWidth == 10);

    frame.borderStyle = BorderStyle.flat;
    assert(frame.borderStyle == BorderStyle.flat);

    frame.borderStyle = BorderStyle.sunken;
    assert(frame.borderStyle == BorderStyle.sunken);

    assert(frame.padding == Padding());

    frame.padding = Padding(10);
    assert(frame.padding == Padding(10));

    frame.padding = Padding(10, 20);
    assert(frame.padding == Padding(10, 20));

    frame.padding = Padding(10, 20, 30);
    assert(frame.padding == Padding(10, 20, 30));

    frame.padding = Padding(10, 20, 30, 40);
    assert(frame.padding == Padding(10, 20, 30, 40));

    frame.padding = Padding(0, 0, 0, 10);
    assert(frame.padding == Padding(0, 0, 0, 10));

    frame.padding = Padding(0, 0, 10, 20);
    assert(frame.padding == Padding(0, 0, 10, 20));

    frame.padding = Padding(0, 10, 20, 30);
    assert(frame.padding == Padding(0, 10, 20, 30));

    frame.padding = Padding(10, 20, 30, 40);
    assert(frame.padding == Padding(10, 20, 30, 40));

    frame.padding = Padding(10, 10, 10, 10);

    app.testRun(1.seconds);
}

