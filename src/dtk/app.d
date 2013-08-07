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

/** The main dtk application. Once instantiated a main window will be created. */
final class App
{
    /** Create the app and a main window. */
    this()
    {
        _interp = enforce(Tcl_CreateInterp());

        enforce(Tcl_Init(_interp) == TCL_OK, to!string(_interp.result));
        enforce(Tk_Init(_interp) == TCL_OK, to!string(_interp.result));

        _window = new Window(enforce(Tk_MainWindow(_interp)));
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

    /** Evaluate any Tcl command and return its result. */
    public static string eval(string cmd)
    {
        stderr.writefln("tcl_eval { %s }", cmd);
        Tcl_Eval(_interp, cast(char*)toStringz(cmd));
        return to!string(_interp.result);
    }

private:
    void exit()
    {
        Tcl_DeleteInterp(_interp);
    }

package:
    /** Only one interpreter is allowed. */
    __gshared Tcl_Interp* _interp;

private:
    Window _window;
}
