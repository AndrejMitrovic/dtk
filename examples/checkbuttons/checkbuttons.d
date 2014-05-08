/*
 *             Copyright Andrej Mitrovic 2014.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module checkbuttons;

import std.string : format;

import dtk;

void main()
{
    auto app = new App();

    // Get the reference to the implicitly created main window.
    auto window = app.mainWindow;
    window.title = "Checkbuttons example";
    window.size = Size(180, 100);

    // Position it in the center.
    window.centerWindow();

    // Create a toggleable button.
    auto button = new CheckButton(window);

    // set specific on and off values when the button is toggled.
    button.onValue = "blue";
    button.offValue = "red";

    // Create a label next to the button.
    auto label = new Label(window, "This label will display the state");

    // lay out the two widgets next to each other.
    button.grid.setRow(0).setColumn(0);
    label.grid.setRow(0).setColumn(1);

    // A checkbutton event handler.
    auto handler = (scope CheckButtonEvent event)
    {
        string text = format("Button has been toggled %s\nto the value: '%s'",
                             event.action == CheckButtonAction.toggleOn ? "on" : "off",
                             event.button.value);
        label.text = text;
    };

    // connect the event handler to the checkbutton.
    button.onCheckButtonEvent ~= handler;

    // we can also handle label clicks.
    label.onMouseEvent ~=
        (scope MouseEvent event)
        {
            if (event.action == MouseAction.press)
                button.toggle();
        };

    // Destroy the window when Escape is hit.
    window.onKeyboardEvent ~=
        (scope KeyboardEvent event)
        {
            if (event.keySym == KeySym.Escape)
                window.destroy();
        };

    app.run();
}
