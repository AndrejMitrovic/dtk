/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.loader;

import std.exception;

import dtk.dispatch;
import dtk.interpreter;
import dtk.types;
import dtk.utils;

import dtk.widgets.widget;

/** Used for Tcl string literal escape rules. */
string[dchar] _tclTransTable;

version (Windows)
{
    import core.runtime;
    import dtk.platform.win32.defs;
    import dtk.platform.win32.dragdrop;

    private void loadSymbol(alias field)(HANDLE handle)
    {
        enum string symbolName = __traits(identifier, field);
        field = cast(typeof(field))enforce(GetProcAddress(handle, symbolName.toStringz),
                                           format("Failed to load function pointer: '%s'.", symbolName));
    }

    shared static this()
    {
        enum tclDll = "tcl86.dll";
        HMODULE hTcl = enforce(LoadLibraryA(tclDll), format("'%s' not found in PATH.", tclDll));

        foreach (string member; __traits(allMembers, TclProcs))
            hTcl.loadSymbol!(__traits(getMember, TclProcs, member));

        enum tkDll = "tk86.dll";
        HMODULE hTk = enforce(LoadLibraryA(tkDll), format("'%s' not found in PATH.", tkDll));

        foreach (string member; __traits(allMembers, TkProcs))
            hTk.loadSymbol!(__traits(getMember, TkProcs, member));

        // Since we might need the app name we do it here instead of asking
        // the user to pass it via main(string[] args).
        string appName = Runtime.args[0];

        // This call is apparently required before all other Tcl/Tk calls on some systems.
        Tcl_FindExecutable(appName.toStringz);

        _tclTransTable['"'] = `\"`;
        _tclTransTable['$'] = r"\$";
        _tclTransTable['['] = r"\[";
        _tclTransTable[']'] = r"\]";
        _tclTransTable['\\'] = r"\\";
        _tclTransTable['{'] = r"\{";
        _tclTransTable['}'] = r"\}";

        auto oleRes = OleInitialize(null);
        if (oleRes != S_OK)
        {
            OleUninitialize();
            enforce(0, format("OleInitialize failed with: %s", oleRes));
        }

        _initDragDrop();

        /** Initialize DTK classes. */
        Interpreter.initClass();
        Dispatch.initClass();
        Widget.initClass();
    }

    shared static ~this()
    {
        OleUninitialize();

        /** Release DTK classes. */
        Interpreter.releaseClass();
    }
}
else
static assert(0, "OS not yet supported.");
