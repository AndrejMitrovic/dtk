module dtk.tests.globals;

version(unittest):
version(DTK_UNITTEST):

import std.stdio;

/** One app and one main window for testing. */
import dtk.app;
import dtk.geometry;
import dtk.window;

import dtk.tests.runner;

__gshared App app;
__gshared Window mainWindow;

/// logging for unittests
void log(Args...)(Args args)
{
    version (DTK_LOG_TESTS)
    {
        stderr.writeln(args);
    }
}

/// formatted logging for unittests
void logf(Args...)(Args args)
{
    version (DTK_LOG_TESTS)
    {
        stderr.writefln(args[0], args[1 .. $]);
    }
}

shared static this()
{
    app = new App();
    mainWindow = app.mainWindow;
    mainWindow.position = Point(500, 500);
    unitTester.setTester();
}

shared static ~this()
{
    app.exit();
}
