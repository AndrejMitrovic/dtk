module dtk.tests.test_slider;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk;

import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto slider = new Slider(testWindow, Orientation.horizontal, 200);
    slider.pack();

    assert(slider.minValue > -1.0 && slider.minValue < 1.0);
    assert(slider.maxValue > 99.0 && slider.maxValue < 101.0);

    assert(slider.value == 0.0);
    slider.value = 50.0;

    //~ slider.onEvent.connect(
        //~ (Widget widget, Event event)
        //~ {
            //~ if (event.type == EventType.TkScaleChange)
            //~ {
                //~ logf("Current slider value: %s.", event.state);
            //~ }
        //~ }
    //~ );

    app.testRun();
}
