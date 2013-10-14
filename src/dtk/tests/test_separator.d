/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.test_separator;

version(unittest):
version(DTK_UNITTEST):

import dtk;
import dtk.imports;
import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto button1 = new Button(testWindow, "button 1");
    auto button2 = new Button(testWindow, "button 2");

    auto separator1 = new Separator(testWindow, Angle.horizontal);
    assert(separator1.angle == Angle.horizontal);

    button1.grid
        .setCol(0)
        .setRow(0)
        .setSticky(Sticky.nsew)
        .setPadX(5)
        .setPadY(5);

    separator1.grid
        .setCol(0)
        .setRow(1)
        .setSticky(Sticky.nsew);

    button2.grid
        .setCol(0)
        .setRow(2)
        .setSticky(Sticky.nsew)
        .setPadX(5)
        .setPadY(5);

    auto button3 = new Button(testWindow, "button 3");
    auto button4 = new Button(testWindow, "button 4");

    auto separator2 = new Separator(testWindow, Angle.vertical);
    assert(separator2.angle == Angle.vertical);

    button3.grid
        .setCol(0)
        .setRow(3)
        .setSticky(Sticky.nsew)
        .setPadX(5)
        .setPadY(5);

    separator2.grid
        .setCol(1)
        .setRow(3)
        .setSticky(Sticky.nsew);

    button4.grid
        .setCol(2)
        .setRow(3)
        .setSticky(Sticky.nsew)
        .setPadX(5)
        .setPadY(5);

    app.testRun();
}
