/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.cursor;

version(unittest):
version(DTK_UNITTEST):

import dtk;
import dtk.imports;
import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto label = new Label(testWindow);
    label.grid.setRow(0).setCol(0).setColSpan(2);
    label.text = "Some other cursor";

    assert(app.mainWindow.cursor == Cursor.inherited);
    assert(label.cursor == Cursor.inherited);

    label.cursor = Cursor.watch;
    assert(label.cursor == Cursor.watch);

    label.cursor = Cursor.inherited;
    assert(label.cursor == Cursor.inherited);

    app.testRun();
}
