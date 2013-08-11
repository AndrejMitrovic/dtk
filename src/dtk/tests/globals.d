module dtk.tests.globals;

version(unittest):

/** One app and one main window for testing. */
import dtk.app;
import dtk.window;

__gshared App app;
__gshared Window mainWindow;

shared static this()
{
    app = new App();
    mainWindow = app.mainWindow;
}

shared static ~this()
{
    app.exit();
}
