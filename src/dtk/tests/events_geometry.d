/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.events_geometry;

version(unittest):

import dtk;
import dtk.imports;
import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);

    Point position;
    Size size;
    int borderWidth;

    size_t callCount;
    size_t expectedCallCount;

    auto handler = (scope GeometryEvent e)
    {
        // Disabled: Geometry manager is either misbehaving or I'm not reading the docs properly:
        // http://stackoverflow.com/questions/18043720/odd-results-for-wm-geometry
        // It could be that the main loop has to be running when we're testing these, or
        // there's multiple geometry events generated for a single reposition/resize/border change.
        // assert(e.position == position, text(e.position,  " != ", position));
        // assert(e.size == size, text(e.size, " != ", size));

        // Disabled: %B seems to return zero.
        // See: https://groups.google.com/forum/#!topic/comp.lang.tcl/UxYOariAccw
        // assert(e.borderWidth == borderWidth, text(e.borderWidth, " != ", borderWidth));

        ++callCount;
    };

    position = testWindow.position;
    size = testWindow.size;
    borderWidth = testWindow.borderWidth;

    testWindow.onGeometryEvent ~= handler;

    size = Size(150, 200);
    testWindow.size = size;
    assert(testWindow.size == size);
    ++expectedCallCount;

    position = Point(250, 200);
    testWindow.position = position;
    assert(testWindow.position == position);
    ++expectedCallCount;

    // Disabled: %B seems to return zero.
    // See: https://groups.google.com/forum/#!topic/comp.lang.tcl/UxYOariAccw
    // borderWidth = 10;
    // testWindow.borderWidth = borderWidth;
    // ++expectedCallCount;

    app.testRun();

    // Disabled: There's an amount of additional calls when a window is resized, the count can't be reliably predicted.
    // assert(callCount == expectedCallCount, text(callCount, " != ", expectedCallCount));

    assert(callCount);  // assert there's at least one call
}
