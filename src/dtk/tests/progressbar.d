/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.progressbar;

version(unittest):

import dtk;
import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto bar = new Progressbar(testWindow, ProgressMode.determinate, Angle.horizontal, 200);
    bar.pack();

    assert(bar.angle == Angle.horizontal);
    assert(bar.length == 200);
    assert(bar.progressMode == ProgressMode.determinate);
    assert(bar.maxValue > 99.0 && bar.maxValue < 101.0);
    assert(bar.value == 0.0);

    bar.angle = Angle.vertical;
    assert(bar.angle == Angle.vertical);

    bar.length = 100;
    assert(bar.length == 100);

    bar.progressMode = ProgressMode.indeterminate;
    assert(bar.progressMode == ProgressMode.indeterminate);

    bar.maxValue = 50;
    assert(bar.maxValue > 49.0 && bar.maxValue < 51.0);

    bar.value = 25.0;
    assert(bar.value > 24.0 && bar.value < 26.0);

    bar.start(20);

    app.testRun();  // avoid infinite running time
}
