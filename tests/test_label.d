module test_label;

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
    window.size = Size(100, 100);

    auto label = new Label(window);
    label.pack();

    label.text = "some note\nsome larger note 2\nsmall note";
    assert(label.text == "some note\nsome larger note 2\nsmall note");

    assert(label.anchor == Anchor.none);

    label.size = Size(100, 100);

    label.anchor = Anchor.center;
    assert(label.anchor == Anchor.center);

    label.bgColor = RGB(64, 64, 64);
    assert(label.bgColor == RGB(64, 64, 64));

    label.fgColor = RGB(0, 128, 255);
    assert(label.fgColor == RGB(0, 128, 255));

    assert(label.justification == Justification.none);

    label.justification = Justification.left;
    assert(label.justification == Justification.left);

    //~ label.padding = Padding(10, 10, 10, 10);
    //~ assert(label.padding == Padding(10, 10, 10, 10));

    app.run();
}

