/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.globals;

version(unittest):

// Symbol conflict, issue: http://d.puremagic.com/issues/show_bug.cgi?id=11065
/* package: */  // should only be used in the test-suite

/** One app and one main window for testing. */
import dtk.app;
import dtk.geometry;
import dtk.widgets.window;

import core.runtime;

__gshared App app;

/// logging for unittests
package void log(Args...)(Args args)
{
    version (DTK_LOG_TESTS)
    {
        writeln(args);
    }
}

/// formatted logging for unittests
package void logf(Args...)(Args args)
{
    version (DTK_LOG_TESTS)
    {
        writefln(args[0], args[1 .. $]);
    }
}

version (Windows)
{
    import dtk.platform.win32.defs;
    extern(Windows) HWND GetConsoleWindow();
}

shared static this()
{
    version (Windows)
    {
        // no console when using subsystem:windows
        if (!GetConsoleWindow())
        {
            stdout.open(r".\..\build\dtktest_stdout.log", "w");
            stderr.open(r".\..\build\dtktest_stderr.log", "w");
        }
    }

    app = new App();

    // @bug: No stack trace for null object access in module ctor
    // http://d.puremagic.com/issues/show_bug.cgi?id=10851
    assert(app.mainWindow !is null);
    app.mainWindow.position = Point(500, 500);
    Runtime.extendedModuleUnitTester = &customModuleUnitTester;
}

/// Enables filtering tests via the 'dtest' environment variable
private UnitTestResult customModuleUnitTester ()
{
    import std.algorithm;
    import std.parallelism;
    import std.process;
    import std.range;
    import std.stdio;
    import std.string;
    import std.uni;
    import core.atomic;
    import core.sync.mutex;

    string[] skip_mods = environment.get("dskip").toLower().split(",");
    string filter = environment.get("dtest").toLower();
    size_t filtered;

    struct ModTest
    {
        string name;
        void function() test;
    }

    ModTest[] mod_tests;
    LForeach: foreach (ModuleInfo* mod; ModuleInfo)
    {
        if (mod is null)
            continue;

        auto fp = mod.unitTest;
        if (fp is null)
            continue;

        // only run this repo's tests, not any dependencies
        if (mod.name.startsWith("dtk"))
        {
            if (filter.length > 0 &&
                !canFind(mod.name.toLower(), filter))
            {
                filtered++;
                continue;
            }

            foreach (skip_mod; skip_mods)
            {
                if (canFind(mod.name.toLower(), skip_mod))
                {
                    filtered++;
                    continue LForeach;
                }
            }

            mod_tests ~= ModTest(mod.name, fp);
        }
    }

    shared size_t executed;
    shared size_t passed;
    shared Mutex print_lock = new shared Mutex();

    void runTest (ModTest mod)
    {
        atomicOp!"+="(executed, 1);
        try
        {
            //writefln("Unittesting %s..", mod.name);
            mod.test();
            atomicOp!"+="(passed, 1);
        }
        catch (Throwable ex)
        {
            synchronized (print_lock)
            {
                writefln("Module tests failed: %s", mod.name);
                writeln(ex);
            }
        }
    }

    foreach (mod; mod_tests)
        runTest(mod);

    UnitTestResult result = { executed : executed, passed : passed };
    if (filtered > 0)
        writefln("Ran %s/%s tests (%s filtered)", result.executed,
            result.executed + filtered, filtered);

    result.runMain = false;
    return result;
}
