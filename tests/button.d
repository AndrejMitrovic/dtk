module button;

import std.stdio;

import dtk;

void main()
{
    auto root = new Tk();

    Button button1;
    button1 = new Button(root, "Flash",
        (Widget, Event)
        {
            assert(button1.isActive &&
                   button1.isFocused &&
                   !button1.isPressed &&
                   !button1.isSelected &&
                   button1.isHovered);
        });

    button1.pack();

    testButton(button1);

    root.mainloop();
}

void testButton(Button button)
{
    /** Options tests. */
    assert(button.underline == -1);
    button.underline = 2;
    assert(button.underline == 2);

    /** State tests. */
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
