module button;

import core.thread;

import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk;

void main()
{
    auto app = new App();

    auto window = app.mainWindow;

    auto frame = new Frame(window, Padding(10, 10, 10, 10));

    auto button1 = new Button(frame, "Flash");
    frame.pack();
    button1.pack();

    assert(frame.size == Size(0, 0));

    frame.size = Size(100, 100);
    stderr.writeln(frame.size);
    assert(frame.size == Size(100, 100));

    frame.borderWidth = 10;
    assert(frame.borderWidth == 10);

    frame.borderStyle = BorderStyle.flat;
    assert(frame.borderStyle == BorderStyle.flat);

    frame.borderStyle = BorderStyle.sunken;
    assert(frame.borderStyle == BorderStyle.sunken);

    app.run();
}

