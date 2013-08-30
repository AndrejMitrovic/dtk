/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.interpreter;

import std.stdio;
import std.c.stdlib;

import std.exception;
import std.string;
import std.conv;
import std.path;

import dtk.event;
import dtk.loader;
import dtk.types;

import dtk.widgets.widget;
import dtk.widgets.window;

/** Evaluate any Tcl command and return its result. */
string tclEval(string cmd)
{
    return Interpreter.eval(cmd);
}

/** Ditto, but use a format string as a convenience. */
string tclEvalFmt(T...)(string fmt, T args)
{
    return Interpreter.eval(format(fmt, args));
}

/** Return the global Tcl interpreter. */
@property Tcl_Interp* tclInterp()
{
    return Interpreter._interp;
}

/** The single Tcl interpreter. */
package abstract final class Interpreter
{
    /** Initialize the Interpreter and the Tcl and Tk libraries. */
    package static void initialize()
    {
        _interp = enforce(Tcl_CreateInterp(), "Couldn't create the Tcl interpreter.");

        enforce(Tcl_Init(_interp) == TCL_OK, to!string(_interp.result));
        enforce(Tk_Init(_interp) == TCL_OK, to!string(_interp.result));
    }

    /** Release the interpreter resources. */
    package static void release()
    {
        Tcl_DeleteInterp(_interp);
        _interp = null;
    }

    /** Evaluate any Tcl command and return its result. */
    private static string eval(string cmd)
    {
        version (DTK_LOG_EVAL)
            stderr.writefln("tcl_eval %s", cmd);

        Tcl_Eval(_interp, cast(char*)toStringz(cmd));
        return to!string(_interp.result);
    }

package:
    __gshared Tcl_Interp* _interp;
}
