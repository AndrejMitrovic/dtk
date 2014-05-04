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
    auto window = app.mainWindow;

    window.title = "Buttons example";
    window.size = Size(180, 100);

    auto blueButton = new Button(window, "blue");
    blueButton.pack();

    auto redButton = new Button(window, "red");
    redButton.pack();

    auto status = new Label(window, "Clicked button is shown here.");
    status.pack();

    // a generic button event handler
    auto handler = (scope ButtonEvent event)
    {
        if (event.action == ButtonAction.push
            && event.widget.widgetType == WidgetType.button)
        {
            auto button = cast(Button)event.widget;
            status.text = format("Clicked button '%s'.", button.text);
        }
    };

    blueButton.onButtonEvent ~= handler;
    redButton.onButtonEvent ~= handler;

    app.run();
}
