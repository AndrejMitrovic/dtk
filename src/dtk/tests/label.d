/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.label;

version(unittest):

import dtk;
import dtk.tests.globals;

import std.conv;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto label = new Label(testWindow);
    label.pack();

    assert(label.underline == -1);
    label.underline = 2;
    assert(label.underline == 2);

    label.text = "some note\nsome larger note 2\nsmall note";
    assert(label.text == "some note\nsome larger note 2\nsmall note");

    label.anchor = Anchor.n;
    assert(label.anchor == Anchor.n, label.anchor.text);

    label.textWidth = 100;
    assert(label.textWidth == 100);

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

    assert(label.compound == Compound.none);

    label.compound = Compound.center;
    assert(label.compound == Compound.center);

    assert(label.textWidth == 100, label.textWidth.text);  // seems to be 100 initially
    label.textWidth = -50;  // set minimum 50 units
    assert(label.textWidth == -50);

    label.textWidth = 0;
    assert(label.textWidth == 0);

    label.textWidth = 50;   // set maximum 50 units
    assert(label.textWidth == 50);

    app.testRun();
}

