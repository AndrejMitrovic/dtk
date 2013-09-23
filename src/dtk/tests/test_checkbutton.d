/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.test_checkbutton;

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

    CheckButton button1;
    button1 = new CheckButton(testWindow, "Flash");

    CheckButtonAction action;
    size_t expectedCallCount;
    size_t callCount;

    auto handler = (scope CheckButtonEvent e)
    {
        assert(e.widget is button1);
        assert(e.button is button1);
        assert(e.action == action);
        ++callCount;
    };

    button1.onCheckButtonEvent ~= handler;

    assert(button1.onValue == "1", button1.onValue);
    button1.onValue = "on value";
    assert(button1.onValue == "on value");

    assert(button1.offValue == "0");
    button1.offValue = "off value";
    assert(button1.offValue == "off value");

    button1.focus();
    button1.pack();

    action = CheckButtonAction.toggleOn;
    button1.toggleOn();
    assert(button1.value == button1.onValue());
    ++expectedCallCount;

    action = CheckButtonAction.toggleOff;
    button1.toggleOff();
    assert(button1.value == button1.offValue());
    ++expectedCallCount;

    action = CheckButtonAction.toggleOn;
    button1.toggle();
    assert(button1.value == button1.onValue());
    ++expectedCallCount;

    testStandard(button1);
    testButton(button1);

    app.testRun();

    assert(callCount == expectedCallCount, text(callCount, " != ", expectedCallCount));
}

// test button-specific options
void testButton(CheckButton button)
{
    assert(button.underline == -1);
    button.underline = 2;
    assert(button.underline == 2);

    assert(button.style == ButtonStyle.none);
    button.style = ButtonStyle.toolButton;
    assert(button.style == ButtonStyle.toolButton);
    button.style = ButtonStyle.none;

    assert(button.text == "Flash");
    button.text = "this is some long text";
    assert(button.text == "this is some long text", button.text);

    assert(button.textWidth == 0);  // natural width
    button.textWidth = -50;  // set minimum 50 units
    assert(button.textWidth == -50);

    button.textWidth = 0;
    assert(button.textWidth == 0);

    button.textWidth = 50;   // set maximum 50 units
    assert(button.textWidth == 50);
}

// test standard widget states
void testStandard(Widget button)
{
    assert(button.isEnabled);
    assert(!button.isDisabled);

    button.disable();
    assert(!button.isEnabled);
    assert(button.isDisabled);

    button.enable();
    assert(button.isEnabled);
    assert(!button.isDisabled);

    assert(!button.isActive);
    assert(!button.isFocused);
    assert(!button.isPressed);
    //~ assert(button.isSelected);
    assert(!button.isInBackground);
    assert(!button.isReadOnly);
    assert(!button.isAlternate);
    assert(!button.isInvalid);
    assert(!button.isHovered);
}
