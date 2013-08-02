/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.loader;

import std.exception;

import dtk.types;
import dtk.utils;

version (Windows)
{
    import core.runtime;
    import std.c.windows.windows;
    import std.string;

    private void loadSymbol(alias field)(HANDLE handle)
    {
        enum string symbolName = __traits(identifier, field);
        field = cast(typeof(field))enforce(GetProcAddress(handle, symbolName.toStringz),
                                           format("Failed to load function pointer: '%s'.", symbolName));
    }

    shared static this()
    {
        HMODULE hTcl = enforce(LoadLibraryA("tcl86.dll"));

        foreach (string member; __traits(allMembers, TclProcs))
            hTcl.loadSymbol!(__traits(getMember, TclProcs, member));

        HMODULE hTk = enforce(LoadLibraryA("tk86.dll"));

        foreach (string member; __traits(allMembers, TkProcs))
            hTk.loadSymbol!(__traits(getMember, TkProcs, member));

        // Since we might need the app name we do it here instead of asking
        // the user to pass it via main(string[] args).
        string appName = Runtime.args[0];

        // This call is apparently required before all other Tcl/Tk calls on some systems,
        // but we'll call it on all systems to be sure.
        Tcl_FindExecutable(appName.toStringz);
    }
}
else
static assert(0, "OS not yet supported.");
