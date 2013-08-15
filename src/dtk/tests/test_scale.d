module dtk.tests.test_scale;

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
    auto scale = new Scale(app.mainWindow, Orientation.horizontal, 200);
    scale.pack();

    assert(scale.minValue > -1.0 && scale.minValue < 1.0);
    assert(scale.maxValue > 99.0 && scale.maxValue < 101.0);

    assert(scale.value == 0.0);
    scale.value = 50.0;

    scale.onEvent.connect(
        (Widget widget, Event event)
        {
            if (event.type == EventType.TkScaleChange)
            {
                logf("Current scale value: %s.", event.state);
            }
        }
    );

    app.testRun();
}
