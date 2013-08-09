module test_checkbutton;

import core.thread;

import std.range;
import std.stdio;
import std.string;

import dtk;

void main()
{
    auto app = new App();

    CheckButton button1;
    button1 = new CheckButton(app.mainWindow, "Flash");

    button1.onEvent.connect(
    (Widget widget, Event event)
    {
        static size_t pressCount;

        switch (event.type) with (EventType)
        {
            case TkCheckButtonToggle:
                stderr.writefln("Button toggled to: %s.", event.state);
                break;

            default:
        }

        //~ stderr.writefln("Event: %s", event);
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
    button1.toggleOff();
    button1.toggle();

    testStandard(button1);
    testButton(button1);

    app.run();
}


// test button-specific options
void testButton(CheckButton button)
{
    assert(button.style == ButtonStyle.none);
    button.style = ButtonStyle.toolButton;
    assert(button.style == ButtonStyle.toolButton);
    button.style = ButtonStyle.none;
}

// test standard widget states
void testStandard(Widget button)
{
    assert(button.underline == -1);
    button.underline = 2;
    assert(button.underline == 2);

    assert(button.width == 0);  // natural width
    button.width = -50;  // set minimum 50 units
    assert(button.width == -50);

    button.width = 0;
    assert(button.width == 0);

    button.width = 50;   // set maximum 50 units
    assert(button.width == 50);

    assert(button.text == "Flash");
    button.text = "this is some long text";
    assert(button.text == "this is some long text", button.text);

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

    assert(button.genericStyle.empty);
    button.genericStyle = "Toolbutton";
    assert(button.genericStyle == "Toolbutton");
    button.genericStyle = "";
}
