/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.events_destroy;

version(unittest):

import dtk;
import dtk.imports;
import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);

    bool handled;
    testWindow.onDestroyEvent ~= (scope DestroyEvent e) { handled = true; };
    testWindow.destroy();

    app.testRun();
    assert(handled); // todo: the new code doesn't immediately trigger
}
