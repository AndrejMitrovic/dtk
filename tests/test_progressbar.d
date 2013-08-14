module test_progressbar;

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

    auto bar1 = new Progressbar(app.mainWindow, Orientation.horizontal, 200, ProgressMode.determinate);

    assert(bar1.maxValue > 99.0 && bar1.maxValue < 101.0);

    assert(bar1.value == 0.0);
    bar1.value = 50.0;

    auto bar2 = new Progressbar(app.mainWindow, Orientation.horizontal, 200, ProgressMode.indeterminate);

    bar2.start(100);

    bar2.onEvent.connect(
        (Widget widget, Event event)
        {
            if (event.type == EventType.TkProgressbarChange)
            {
                stderr.writefln("Current progress: %s.", event.state);

                float progress = to!float(event.state);
                if (bar2.isRunning && progress > 10.0)
                {
                    // Note: doesn't work, see bug report:
                    // https://core.tcl.tk/tk/tktview/c597acdab39212f2b5557e69e38eb3191f4a5927
                    bar2.stop();
                    stderr.writefln("Stopping progress at: %s.", progress);
                }
            }
        }
    );

    bar1.pack();
    bar2.pack();

    app.run();
}

void main()
{
}
