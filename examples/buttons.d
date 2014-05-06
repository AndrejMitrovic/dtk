/*
 *             Copyright Andrej Mitrovic 2014.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module buttons;

import std.string : format;

import dtk;

void main()
{
    auto app = new App();

    // Get the reference to the implicitly created main window.
    auto window = app.mainWindow;
    window.title = "Buttons example";
    window.size = Size(180, 80);

    // Position it in the center.
    window.centerWindow();

    // Create a clickable button.
    auto blueButton = new Button(window, "blue");
    blueButton.pack();

    // Create another one.
    auto redButton = new Button(window, "red");
    redButton.pack();

    // Create a label that will have its text field updated when
    // either of the buttons is clicked.
    auto status = new Label(window, "Clicked button is shown here.");
    status.pack();

    // A generic button event handler.
    auto handler = (scope ButtonEvent event)
    {
        if (event.action == ButtonAction.push)
            status.text = format("Clicked button '%s'.", event.button.text);
    };

    // Connect the generic event handler to both buttons.
    blueButton.onButtonEvent ~= handler;
    redButton.onButtonEvent ~= handler;

    // Destroy the window when Escape is hit.
    window.onKeyboardEvent ~=
        (scope KeyboardEvent event)
        {
            if (event.keySym == KeySym.Escape)
                window.destroy();
        };

    app.run();
}
