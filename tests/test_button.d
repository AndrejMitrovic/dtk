module button;

import std.stdio;
import std.range;

import dtk;

void main()
{
    auto app = new App();

    Button button1;
    button1 = new Button(app.mainWindow, "Flash");

    // note: be wary of Issue 7198 http://d.puremagic.com/issues/show_bug.cgi?id=7198
    button1.onPress.connect(
        (Widget widget, Event event)
        {
            static int counter;
            counter++;

            // the first time the invocation is explicit via fireEvent
            //~ if (counter == 1)
            //~ {
                //~ assert(!button1.isActive &&
                       //~ !button1.isFocused &&
                       //~ !button1.isPressed &&
                       //~ !button1.isSelected &&
                       //~ !button1.isHovered);
            //~ }
            //~ else  // invocation via mouse click
            //~ {
                //~ assert(button1.isActive &&
                       //~ button1.isFocused &&
                       //~ !button1.isPressed &&
                       //~ !button1.isSelected &&
                       //~ button1.isHovered);
            //~ }

            button1.text = "Flash";
            assert(button1.text == "Flash");

            stderr.writefln("onEvent called %s times - for widget %s - event is: %s.", counter, widget, event);
        });

    button1.onMouseEnter.connect(
        (Widget w, Event e)
        {
            stderr.writefln("Mouse entered button area, event: %s.", e);
        });

    button1.onMouseLeave.connect(
        (Widget w, Event e)
        {
            stderr.writefln("Mouse leaved button area, event: %s.", e);
        });

    button1.pack();

    testStandard(button1);
    testButton(button1);

    app.run();
}

// test button-specific options
void testButton(Button button)
{
    button.fireEvent();

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
