module dtk.tests.globals;

version(unittest):

/** One app and one main window for testing. */
import dtk.app;
import dtk.window;

__gshared App app;
__gshared Window mainWindow;

import std.stdio;

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
}

shared static ~this()
{
    app.exit();
}
