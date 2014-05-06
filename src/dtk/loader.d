/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.loader;

import dtk.dispatch;
import dtk.imports;
import dtk.interpreter;
import dtk.types;
import dtk.utils;

import dtk.widgets.widget;

/** Used for Tcl string literal escape rules. */
string[dchar] _tclTransTable;

version (Windows)
{
    import dtk.platform.win32.defs;
    import dtk.platform.win32.dragdrop;

    alias LibHandle = HANDLE;

    enum tclDll = "tcl86.dll";
    enum tkDll = "tk86.dll";

    alias loadLib = LoadLibraryA;
    alias loadProc = GetProcAddress;
    alias freeLib = FreeLibrary;
}
else
version (Posix)
{
    import std.c.linux.linux;
    import dtk.platform.posix.dragdrop;

    alias LibHandle = void*;

    enum tclDll = "libtcl8.6.so";
    enum tkDll = "libtk8.6.so";

    auto loadLib(string libName)
    {
        return dlopen(libName.toStringz, RTLD_NOW);
    }

    alias loadProc = dlsym;
    alias freeLib = dlclose;
}
else
static assert(0, "OS not yet supported.");

private void loadSymbol(alias field)(LibHandle handle)
{
    enum string symbolName = __traits(identifier, field);
    field = cast(typeof(field))enforce(loadProc(handle, symbolName.toStringz),
                                       format("Failed to load function pointer: '%s'.", symbolName));
}

private __gshared LibHandle tclLib;
private __gshared LibHandle tkLib;

shared static this()
{
    tclLib = enforce(loadLib(tclDll), format("'%s' not found in PATH.", tclDll));

    foreach (string member; __traits(allMembers, TclProcs))
        tclLib.loadSymbol!(__traits(getMember, TclProcs, member));

    tkLib = enforce(loadLib(tkDll), format("'%s' not found in PATH.", tkDll));

    foreach (string member; __traits(allMembers, TkProcs))
        tkLib.loadSymbol!(__traits(getMember, TkProcs, member));

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

    version (Windows)
    {
        auto oleRes = OleInitialize(null);
        if (oleRes != S_OK)
        {
            OleUninitialize();
            enforce(0, format("OleInitialize failed with: %s", oleRes));
        }
        scope (failure) OleUninitialize();
    }

    _initDragDrop();

    /** Initialize DTK classes. */
    Interpreter.initClass();
    scope (failure) Interpreter.releaseClass();

    enum tclReqMajor = 8;
    enum tclReqMinor = 6;
    int tclMajor, tclMinor, tclPatchLevel;

    Tcl_GetVersion(&tclMajor, &tclMinor, &tclPatchLevel, null);
    enforce(tclMajor == tclReqMajor && tclMinor == tclReqMinor,
        format("DTK requires Tcl version %s.%s.+. Found Tcl version %s.%s.%s",
            tclReqMajor,tclReqMinor, tclMajor, tclMinor, tclPatchLevel));

    /** Require Tk 8.6+ (allow minor version mismatch). */
    enum int matchMinorVersion = 0;
    enum string tkReqVersion = "8.6";
    enforce(Tcl_PkgRequire(tclInterp, "Tk", tkReqVersion, matchMinorVersion) !is null,
        format("DTK requires Tk package version %s. %s",
            tkReqVersion, to!string(tclInterp.result)));

    Dispatch.initClass();
    Widget.initClass();
}

shared static ~this()
{
    version (Windows)
    {
        OleUninitialize();
    }

    /** Release DTK classes. */
    Interpreter.releaseClass();

    freeLib(tclLib);
    freeLib(tkLib);
}
