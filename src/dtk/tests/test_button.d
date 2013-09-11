module dtk.tests.test_button;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.range;
import std.stdio;
import std.string;

import dtk;

import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto button1 = new Button(testWindow, "Flash");

    button1.focus();
    button1.pack();

    testStandard(button1);
    testButton(button1);

    size_t expectedCallCount;
    size_t callCount;

    auto handler = (scope ButtonEvent e)
    {
        assert(e.widget is button1);
        assert(e.action == ButtonAction.push);
        ++callCount;
    };

    button1.onButtonEvent ~= handler;
    button1.push();
    ++expectedCallCount;

    app.testRun();

    assert(callCount == expectedCallCount, text(callCount, " != ", expectedCallCount));
}

// test button-specific options
void testButton(Button button)
{
    assert(button.underline == -1);
    button.underline = 2;
    assert(button.underline == 2);

    assert(button.style == ButtonStyle.none);
    button.style = ButtonStyle.toolButton;
    assert(button.style == ButtonStyle.toolButton);
    button.style = ButtonStyle.none;

    assert(button.defaultMode == DefaultMode.normal);
    button.defaultMode = DefaultMode.active;
    assert(button.defaultMode == DefaultMode.active);

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
    assert(!button.isSelected);
    assert(!button.isInBackground);
    assert(!button.isReadOnly);
    assert(!button.isAlternate);
    assert(!button.isInvalid);
    assert(!button.isHovered);
}
