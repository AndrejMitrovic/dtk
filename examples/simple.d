/*
 *             Copyright Andrej Mitrovic 2014.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module simple;

import dtk;

void main()
{
    auto app = new App();

    // Get the reference to the implicitly created main window.
    auto window = app.mainWindow;
    window.title = "Your DTK App";
    window.size = Size(180, 100);

    // Position it in the center.
    window.centerWindow();

    auto label = new Label(window, "Hello world!");
    label.pack();

    // Destroy the window when Escape is hit.
    window.onKeyboardEvent ~=
        (scope KeyboardEvent event)
        {
            if (event.keySym == KeySym.Escape)
                window.destroy();
        };

    app.run();
}
