module dtk.tests.test_progressbar;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.conv;
import std.range;
import std.stdio;
import std.string;

static if (__VERSION__ < 2064)
    import dtk.all;
else
    import dtk;

import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto bar1 = new Progressbar(testWindow, Orientation.horizontal, 200, ProgressMode.determinate);

    assert(bar1.maxValue > 99.0 && bar1.maxValue < 101.0);

    assert(bar1.value == 0.0);
    bar1.value = 50.0;

    auto bar2 = new Progressbar(testWindow, Orientation.horizontal, 200, ProgressMode.indeterminate);

    bar2.start(20);

    bar2.onEvent.connect(
        (Widget widget, Event event)
        {
            if (event.type == EventType.TkProgressbarChange)
            {
                logf("Current progress: %s.", event.state);

                float progress = to!float(event.state);
                if (bar2.isRunning && progress > 5.0)
                {
                    // Note: doesn't work, see bug report:
                    // https://core.tcl.tk/tk/tktview/c597acdab39212f2b5557e69e38eb3191f4a5927
                    bar2.stop();
                    logf("Stopping progress at: %s.", progress);

                    // workaround
                    bar2.onEvent.clear();
                }
            }
        }
    );

    bar1.pack();
    bar2.pack();

    app.testRun(1.seconds, SkipIdleTime.yes);  // avoid infinite running time
}
