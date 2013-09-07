module dtk.tests.test_checkbutton;

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

    CheckButton button1;
    button1 = new CheckButton(testWindow, "Flash");

    button1.onEvent.connect(
    (Widget widget, Event event)
    {
        static size_t pressCount;

        switch (event.type) with (EventType)
        {
            case TkCheckButtonToggle:
                logf("Button toggled to: %s.", event.state);
                break;

            default:
        }

        //~ logf("Event: %s", event);
    });

    assert(button1.onValue == "1", button1.onValue);
    button1.onValue = "foo";
    assert(button1.onValue == "foo");

    assert(button1.offValue == "0");
    button1.offValue = "bar";
    assert(button1.offValue == "bar");

    button1.focus();
    button1.pack();

    button1.toggleOn();
    assert(button1.value == button1.onValue());

    button1.toggleOff();
    assert(button1.value == button1.offValue());

    button1.toggle();
    assert(button1.value == button1.onValue());

    testStandard(button1);
    testButton(button1);

    app.testRun();
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
