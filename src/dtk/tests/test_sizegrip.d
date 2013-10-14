/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.test_sizegrip;

version(unittest):
version(DTK_UNITTEST):

import dtk;
import dtk.imports;
import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    testWindow.disableSizegrip();
    testWindow.enableSizegrip();
    app.testRun();
}
