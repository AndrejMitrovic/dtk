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

package:
    __gshared Tcl_Interp* _interp;
}

/** Evaluate any Tcl command and return its result. */
string tclEval(string cmd)
{
    version (DTK_LOG_EVAL)
        stderr.writefln("tcl_eval %s", cmd);

    Tcl_Eval(tclInterp, cast(char*)toStringz(cmd));
    return to!string(tclInterp.result);
}

/** Ditto, but use a format string as a convenience. */
string tclEvalFmt(T...)(string fmt, T args)
{
    return tclEval(format(fmt, args));
}

/** Get the global Tcl interpreter. */
@property Tcl_Interp* tclInterp()
{
    return Interpreter._interp;
}

/** Get the value of the variable $(D varName) of type $(D T). */
T tclGetVar(T)(string varName)
{
    // todo: use TCL_LEAVE_ERR_MSG
    // todo: check _interp error
    // todo: check all interpreter error codes

    import std.array;
    import std.traits;

    enum getFlags = 0;
    static if (isArray!T && !isSomeString!T)
    {
        Appender!T result;

        auto tclObj = Tcl_GetVar2Ex(tclInterp, cast(char*)varName.toStringz, null, getFlags);
        enforce(tclObj !is null);

        int arrCount;
        Tcl_Obj **array;
        enforce(Tcl_ListObjGetElements(tclInterp, tclObj, &arrCount, &array) != TCL_ERROR);

        foreach (index; 0 .. arrCount)
            result ~= to!string(Tcl_GetString(array[index]));

        return result.data;
    }
    else
    {
        version (DTK_LOG_EVAL)
            stderr.writefln("Tcl_GetVar(%s)", varName);

        return to!T(Tcl_GetVar(tclInterp, cast(char*)varName.toStringz, getFlags));
    }
}

/** Set a new value for the variable $(D varName) of type $(D T) to the value $(D value). */
void tclSetVar(T)(string varName, T value)
{
    import std.array;
    import std.traits;

    static if (isArray!T && !isSomeString!T)
    {
        tclEvalFmt("set %s [list %s]", varName, value.join(" "));
    }
    else
    {
        version (DTK_LOG_EVAL)
            stderr.writefln("Tcl_SetVar(%s, %s)", varName, to!string(value));

        enum setFlags = 0;
        Tcl_SetVar(tclInterp, cast(char*)varName.toStringz, cast(char*)(to!string(value).toStringz), setFlags);
    }
}
