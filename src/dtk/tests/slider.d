/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.slider;

version(unittest):

import dtk;
import dtk.utils;
import dtk.tests.globals;

import std.format;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto slider = new Slider(app.mainWindow, Angle.horizontal, 200);
    slider.pack();

    assert(slider.angle == Angle.horizontal);
    assert(slider.length == 200);
    assert(slider.minValue > -1.0 && slider.minValue < 1.0);
    assert(slider.maxValue > 99.0 && slider.maxValue < 101.0);
    assert(slider.value == 0.0);

    slider.angle = Angle.vertical;
    assert(slider.angle == Angle.vertical);

    slider.length = 100;
    assert(slider.length == 100);

    slider.minValue = 20.0;
    assert(slider.minValue > 19.0 && slider.minValue < 21.0);

    slider.maxValue = 50.0;
    assert(slider.maxValue > 49.0 && slider.maxValue < 51.0);

    slider.value = 35;
    assert(slider.value > 34.0 && slider.value < 36.0);

    size_t callCount;
    size_t expectedCallCount;

    float value = 0;

    slider.onSliderEvent ~= (scope SliderEvent event)
    {
        assert(event.slider is slider);
        assert(event.slider.value > value - 1 && event.slider.value < value + 1);
        ++callCount;
    };

    value = 40;
    slider.value = 40;
    ++expectedCallCount;

    assert(callCount == expectedCallCount, format("%s != %s", callCount, expectedCallCount));

    app.testRun();
}
