module button;

import std.stdio;

import dtk;

void main()
{
    auto root = new Tk();

    Button button1;
    button1 = new Button(root, "Flash");

    button1.onEvent =
        (Widget, Event)
        {
            static int counter;
            counter++;

            // the first time the invocation is explicit via fireEvent
            if (counter == 1)
            {
                assert(!button1.isActive &&
                       !button1.isFocused &&
                       !button1.isPressed &&
                       !button1.isSelected &&
                       !button1.isHovered);
            }
            else  // invocation via mouse click
            {
                assert(button1.isActive &&
                       button1.isFocused &&
                       !button1.isPressed &&
                       !button1.isSelected &&
                       button1.isHovered);
            }

            button1.text = "Flash";
            assert(button1.text == "Flash");

            stderr.writefln("onEvent called %s times.", counter);
        };

    button1.pack();

    testStandard(button1);
    testButton(button1);

    root.mainloop();
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
}

// test button-specific options
void testButton(Button button)
{
    button.fireEvent();
}
