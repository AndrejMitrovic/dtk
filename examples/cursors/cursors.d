/*
 *             Copyright Andrej Mitrovic 2014.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module cursors;

import std.process : browse;

import dtk;

void main()
{
    auto app = new App;

    // Get the reference to the implicitly created main window.
    auto window = app.mainWindow;
    window.title = "Cursors example";
    window.size = Size(180, 100);

    // Position it in the center.
    window.centerWindow();

    // Create a label that displays a busy cursor on hover.
    auto busy = new Label(window);
    busy.text = "Busy cursor.";
    busy.cursor = Cursor.watch;

    // Create a label that displays a link cursor on hover.
    auto link = new Label(window);
    link.text = "www.dlang.org";
    link.cursor = Cursor.hand2;

    // Open a link to dlang.org when the label is clicked,
    // and change the link text color.
    link.onMouseEvent ~=
        (scope MouseEvent event)
        {
            if (event.action == MouseAction.press)
            {
                browse("http://dlang.org");
                link.foreColor = RGB(200, 0, 0);
            }
        };

    // Lay out the two labels in a grid.
    busy.grid.setRow(0).setColumn(0);
    link.grid.setRow(0).setColumn(1);

    // Destroy the window when Escape is hit.
    window.onKeyboardEvent ~=
        (scope KeyboardEvent event)
        {
            if (event.keySym == KeySym.Escape)
                window.destroy();
        };

    app.run();
}
