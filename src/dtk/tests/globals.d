module dtk.tests.globals;

version(unittest):
version(DTK_UNITTEST):

import std.stdio;

/** One app and one main window for testing. */
import dtk.app;
import dtk.geometry;

import dtk.widgets.window;

import dtk.tests.runner;

__gshared App app;

/// logging for unittests
void log(Args...)(Args args)
{
    version (DTK_LOG_TESTS)
    {
        writeln(args);
    }
}

/// formatted logging for unittests
void logf(Args...)(Args args)
{
    version (DTK_LOG_TESTS)
    {
        writefln(args[0], args[1 .. $]);
    }
}

version (Windows)
{
    import core.sys.windows.windows;
    extern(Windows) HWND GetConsoleWindow();
}

shared static this()
{
    version (Windows)
    {
        // no console when using subsystem:windows
        if (!GetConsoleWindow())
        {
            stdout.open(r".\..\build\dtktest_stdout.log", "w");
            stderr.open(r".\..\build\dtktest_stderr.log", "w");
        }
    }

    app = new App();

    // @bug: No stack trace for null object access in module ctor
    // http://d.puremagic.com/issues/show_bug.cgi?id=10851
    assert(app.mainWindow !is null);
    app.mainWindow.position = Point(500, 500);
    unitTester.setTester();

}

shared static ~this()
{
    app.exit();
}
