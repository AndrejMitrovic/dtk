/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.interpreter;

import std.algorithm;
import std.array;
import std.stdio;
import std.traits;
import std.c.stdlib;

import std.exception;
import std.string : translate, toStringz;
import std.path;

import dtk.event;
import dtk.loader;
import dtk.types;
import dtk.utils;

import dtk.widgets.widget;
import dtk.widgets.window;

/** The single Tcl interpreter. */
package abstract final class Interpreter
{
    /** Initialize the Interpreter and the Tcl and Tk libraries. */
    package static void initClass()
    {
        _interp = enforce(Tcl_CreateInterp(), "Couldn't create the Tcl interpreter.");

        enforce(Tcl_Init(_interp) == TCL_OK, to!string(_interp.result));
        enforce(Tk_Init(_interp) == TCL_OK, to!string(_interp.result));
    }

    /** Release the interpreter resources. */
    package static void releaseClass()
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
        stderr.writefln("tcl_eval: %s", cmd);

    enforce(Tcl_Eval(tclInterp, cast(char*)toStringz(cmd)) != TCL_ERROR,
        format("Tcl eval error: %s", to!string(tclInterp.result)));

    auto result = to!string(tclInterp.result);

    return result;
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

/** Create a Tcl variable. */
package void tclMakeVar(string varName)
{
    tclEvalFmt("set %s %s", varName, `""`);
}

/** Create a traced Tcl variable. */
package void tclMakeTracedVar(string varName, string varTag, string callbackName)
{
    tclMakeVar(varName);

    // hook the callback
    tclEvalFmt(`trace add variable %s write [list %s %s $%s]`, varName, callbackName, varTag, varName);
}

/** Get an array of type $(D T) from the tcl_Obj object. */
T tclGetArray(T)(const(Tcl_Obj)* tclObj)
    if (isArray!T && !isSomeString!T)
{
    Appender!T result;

    int arrCount;
    Tcl_Obj **array;
    enforce(Tcl_ListObjGetElements(tclInterp, tclObj, &arrCount, &array) != TCL_ERROR);

    try
    {
        foreach (index; 0 .. arrCount)
            result ~= to!(ElementTypeOf!T)(array[index].tclPeekString());
    }
    catch (ConvException ex)
    {
        ex.msg ~= " - Input was:\n";

        foreach (index; 0 .. arrCount)
        {
            ex.msg ~= array[index].tclGetString();
            ex.msg ~= "\n";
        }

        throw ex;
    }

    return result.data;
}

/** Get the value of the variable $(D varName) of type $(D T). */
T tclGetVar(T)(string varName)
{
    // todo: use TCL_LEAVE_ERR_MSG
    // todo: check _interp error
    // todo: check all interpreter error codes

    enum getFlags = 0;
    static if (isArray!T && !isSomeString!T)
    {
        auto tclObj = Tcl_GetVar2Ex(tclInterp, cast(char*)varName.toStringz, null, getFlags);
        enforce(tclObj !is null);
        return tclGetArray!T(tclObj);
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
        tclEvalFmt("set %s %s", varName, value._tclEscape);
    }
    else
    {
        version (DTK_LOG_EVAL)
            stderr.writefln("Tcl_SetVar(%s, %s)", varName, to!string(value));

        enum setFlags = 0;
        Tcl_SetVar(tclInterp, cast(char*)varName.toStringz, cast(char*)(to!string(value).toStringz), setFlags);
    }
}

/** Return the string of the Tcl object $(D tclObj). */
package string tclGetString(const Tcl_Obj* tclObj)
{
    return tclObj.Tcl_GetString.to!string;
}

/**
    Peek at the string of the Tcl object $(D tclObj).
    The returned string is not allocated, it is only a slice.
    $(D .dup) should be called when assigning to ensure memory safety.
*/
package const(char)[] tclPeekString(const Tcl_Obj* tclObj)
{
    return tclObj.Tcl_GetString().peekCString();
}

version (Windows)
{
    import dtk.platform.win32.defs;

    HWND getHWND(Widget widget)
    {
        Tk_Window tkwin = Tk_NameToWindow(tclInterp, widget.getTclName().toStringz, Tk_MainWindow(tclInterp));
        return Tk_GetHWND(Tk_WindowId(tkwin));
    }
}
