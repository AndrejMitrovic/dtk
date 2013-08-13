module test_combobox;

import core.thread;

import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk;
import dtk.tests.globals;

unittest
{
    auto app = new App;
    auto label = new Label(app.mainWindow);
    label.pack();

    label.text = "some note\nsome larger note 2\nsmall note";
    assert(label.text == "some note\nsome larger note 2\nsmall note");

    label.anchor = Anchor.north;
    assert(label.anchor == Anchor.north, label.anchor.text);

    label.size = Size(100, 100);

    label.anchor = Anchor.center;
    assert(label.anchor == Anchor.center);

    label.bgColor = RGB(64, 64, 64);
    assert(label.bgColor == RGB(64, 64, 64));

    label.fgColor = RGB(0, 128, 255);
    assert(label.fgColor == RGB(0, 128, 255));

    label.bgColorReset();
    label.fgColorReset();

    assert(label.justification == Justification.none);

    label.justification = Justification.left;
    assert(label.justification == Justification.left);

    assert(label.wrapLength == 0);

    label.wrapLength = 50;
    assert(label.wrapLength == 50);

    label.font = GenericFont.text;
    assert(label.font == GenericFont.text);

    label.padding = Padding(10, 10, 10, 10);
    assert(label.padding == Padding(10, 10, 10, 10));

    app.run();
}

void main()
{
}
