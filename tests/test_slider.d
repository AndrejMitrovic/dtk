module test_slider;

import core.thread;

import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk;
import dtk.tests.globals;

unittest
{
    auto app = new App;

    auto slider = new Slider(app.mainWindow, Orientation.horizontal, 200);
    slider.pack();

    assert(slider.minValue > -1.0 && slider.minValue < 1.0);
    assert(slider.maxValue > 99.0 && slider.maxValue < 101.0);

    assert(slider.value == 0.0);
    slider.value = 50.0;

    size_t callCount;
    size_t expectedCallCount;

    slider.onSliderEvent ~= (scope SliderEvent event)
    {
        assert(event.slider is slider);
        assert(event.slider.value == value);
    };

    assert(callCount == expectedCallCount, format("%s != %s", callCount, expectedCallCount));

    app.run();
}

void main()
{
}
