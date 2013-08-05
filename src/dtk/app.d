/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.app;

import std.stdio;
import std.c.stdlib;

import std.exception;
import std.string;
import std.conv;
import std.path;

import dtk.event;
import dtk.loader;
import dtk.types;
import dtk.widget;
import dtk.window;

/** The main Dtk application. Once instantiated a main window will be created. */
final class App
{
    /** Create the app and a main window. */
    this()
    {
        interp = enforce(Tcl_CreateInterp());

        enforce(Tcl_Init(interp) == TCL_OK, to!string(interp.result));
        enforce(Tk_Init(interp) == TCL_OK, to!string(interp.result));

        _window = new Window(enforce(Tk_MainWindow(interp)));
    }

    /** Start the App event loop. */
    void run()
    {
        scope(exit)
            this.exit();

        Tk_MainLoop();
    }

    /** Return the main app window. */
    @property Window mainWindow()
    {
        return _window;
    }

private:
    void exit()
    {
        Tcl_DeleteInterp(interp);
    }

package:
    /** Only one interpreter is allowed. */
    __gshared Tcl_Interp* interp;

private:
    Window _window;
}
