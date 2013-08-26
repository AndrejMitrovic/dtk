module dtk.tests.test_button;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

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

    Button button1;
    button1 = new Button(testWindow, "Flash");

    button1.onEvent.connect(
        (Widget widget, Event event)
        {
            static size_t pressCount;

            switch (event.type) with (EventType)
            {
                case Enter:
                    logf("Mouse entered button area, event: %s.", event);
                    break;

                case Leave:
                    logf("Mouse left button area, event: %s.", event);
                    (cast(Button)widget).push();
                    break;

                case TkButtonPush:
                    logf("Button was pressed %s times.", ++pressCount);
                    break;

                default: assert(0, format("Unhandled event type: %s", event.type));
            }

            logf("Event: %s", event);
        });

    button1.focus();
    button1.pack();

    testStandard(button1);
    testButton(button1);

    app.testRun();
}

// test button-specific options
void testButton(Button button)
{
    assert(button.style == ButtonStyle.none);
    button.style = ButtonStyle.toolButton;
    assert(button.style == ButtonStyle.toolButton);
    button.style = ButtonStyle.none;

    assert(button.defaultMode == DefaultMode.normal);
    button.defaultMode = DefaultMode.active;
    assert(button.defaultMode == DefaultMode.active);
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
    assert(!button.isSelected);
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
