/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
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
__gshared string[dchar] _tclTransTable;

version (Windows)
{
    import dtk.platform.win32.defs;
    import dtk.platform.win32.dragdrop;

    alias LibHandle = HANDLE;

    enum tclSharedLibName = "tcl86t.dll";
    enum tkSharedLibName = "tk86t.dll";

    alias loadLib = LoadLibraryA;
    alias loadProc = GetProcAddress;
    alias freeLib = FreeLibrary;
}
else
version (linux)
{
    import core.sys.posix.dlfcn;
    import dtk.platform.posix.dragdrop;

    alias LibHandle = void*;

    enum tclSharedLibName = "libtcl8.6.so";
    enum tkSharedLibName = "libtk8.6.so";

    auto loadLib(const(char)* libName)
    {
        return dlopen(libName, RTLD_NOW);
    }

    alias loadProc = dlsym;
    alias freeLib = dlclose;
}
else
version (OSX)
{
    import core.sys.posix.dlfcn;
    import dtk.platform.posix.dragdrop;

    alias LibHandle = void*;

    enum tclSharedLibName = "libtcl8.6.dylib";
    enum tkSharedLibName = "libtk8.6.dylib";

    auto loadLib(const(char)* libName)
    {
        return dlopen(libName, RTLD_NOW);
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

version (Windows)
    private enum PathSep = ';';
else version (Posix)
    private enum PathSep = ':';
else
    static assert("Unsupported platform");

version (Windows)
    private enum SharedLibExt = ".dll";
else version (Posix)
    private enum SharedLibExt = ".so";
else
    static assert("Unsupported platform");

/// See below
private struct Pair
{
    string tcl_path;
    string tk_path;
}

/// For each path in the provided environment variable,
/// try to find the pair of Tcl86*.dll / Tk86*.dll.
/// Return a range of (Tcl*.dll / Tk*.dll) tuples
/// It's a little bit hardcoded for the version string,
/// will be improved later.
version (Windows)
private auto getValidPairPaths ()
{
    import std.algorithm;
    import std.array;
    import std.file;
    import std.process;
    import std.string;
    import std.typecons;

    const tcl_glob = format("tcl86*%s", SharedLibExt);
    const tk_glob = format("tk86*%s", SharedLibExt);

    // may throw
    auto path_env = environment["PATH"];

    // linker issue: https://issues.dlang.org/show_bug.cgi?id=20738
    version (none)
    {
        return path_env.splitter(PathSep)
            .map!(path => path.strip)
            .filter!(path => path.length > 0 && path.exists)
            .map!(path =>
                .zip(dirEntries(path, tcl_glob, SpanMode.shallow),
                     dirEntries(path, tk_glob, SpanMode.shallow)));
    }
    else
    {
        Pair[] result;

        foreach (path; path_env.splitter(PathSep)
            .map!(path => path.strip)
            .filter!(path => path.length > 0 && path.exists))
        {
            auto tcl_paths = dirEntries(path, tcl_glob, SpanMode.shallow);
            auto tk_paths = dirEntries(path, tk_glob, SpanMode.shallow);

            foreach (string tcl_path, string tk_path; zip(tcl_paths, tk_paths))
                result ~= Pair(tcl_path, tk_path);
        }

        return result;
    }
}

/// Load the Tcl & Tk shared libs as found in PATH (Windows),
/// or whatever ld loader was configured with (Posix)
private void loadSharedLibs ()
{
    import std.process;

    version (Windows)
    {
        auto paths = getValidPairPaths();
        enforce(!paths.empty,
            "Could not find any Tcl & Tk shared libs in any paths found in PATH");
    }
    version (Posix)
    {
        // this will need to be improved. On Posix the path
        // where the SOs are located may be set in /etc/ld.so.conf,
        // which itself can "include" other .conf files that specify the paths.
        // we could alternatively just try to load tk8.6.so/libtk8.6.so.
        // for now we just try to load the hardcoded SO name and hope LD finds it.
        auto paths = [Pair(tclSharedLibName, tkSharedLibName)];
    }
    else
    {
        static assert("Unsupported platform");
    }

    foreach (pair; paths)
    {
        tclLib = loadLib(pair.tcl_path.toStringz);
        tkLib = loadLib(pair.tk_path.toStringz);

        // just load the first pair match (can be improved later)
        if (tclLib !is null && tkLib !is null)
            break;
    }

    enforce(tclLib !is null && tkLib !is null,
        "Could not load Tcl/Tk shared libs in any paths");

    foreach (string member; __traits(allMembers, TclProcs))
        tclLib.loadSymbol!(__traits(getMember, TclProcs, member));

    foreach (string member; __traits(allMembers, TkProcs))
        tkLib.loadSymbol!(__traits(getMember, TkProcs, member));
}

/// shared lib initialization
shared static this()
{
    loadSharedLibs();

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
