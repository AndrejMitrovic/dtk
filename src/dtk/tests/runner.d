/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.runner;

version(unittest):
version(DTK_UNITTEST):

import dtk.imports;

alias absPath = absolutePath;
alias dirSep = dirSeparator;
alias normPath = buildNormalizedPath;

enum RunMain  { no, yes }
enum RunTests { no, yes }

/** Return a new sorted array. */
T[] sorted(T)(T[] array)
{
    T[] result = array.dup;
    sort(result);
    return result;
}

E[] sortedElements(E, X)(X[E] hash)
{
    E[] elems = hash.keys;
    sort(elems);
    return elems;
}

void add(Hash, Key)(ref Hash hash, Key key)
{
    hash[key] = [];
}

/**
    Pattern match for modules to be tested.
    Supports explicit module names 'a.b.c', and wildcard matching 'a.*'
    If wildcard starts with '*' all modules will match.
*/
struct TestMods
{
    bool empty = true;      // special case when no mods were set
    bool matchAll = false;  // special case when argument is '*'

    this(string[] mods)
    {
        this.empty = mods.empty;

        foreach (mod; mods)
        {
            if (mod.startsWith("*"))
                matchAll = true;
            else
            if (mod.endsWith("*"))
                testFilters.add(mod.findSplitBefore("*")[0]);
            else
                testMods.add(mod);
        }
    }

    bool opIn_r(string mod)
    {
        if (matchAll)
            return true;

        if (mod in testMods)
            return true;

        foreach (filter; testFilters.byKey())
            if (mod.startsWith(filter))
                return true;

        return false;
    }

    unittest
    {
        TestMods tm = TestMods(["a.b.c", "a.b.d", "b.*"]);
        assert("a.b.c" in tm);
        assert("a.b.d" in tm);
        assert("a.b" !in tm);
        assert("b.a" in tm);
        assert("b.b" in tm);
    }

    string[] sortedElements()
    {
        return testMods.sortedElements() ~ testFilters.sortedElements();
    }

    void[][string] testMods;        // e.g. Set("a.b.c", "d.e.f")
    void[][string] testFilters;     // e.g. Set("a.b.*", "d.e.*")
}

/** Non-instantiable unit tester class. */
final abstract class unitTester
{
static:
    /**
        Set the unittest tester after parsing the
        runtime arguments and configuring the tester.
    */
    public void setTester()
    {
        Runtime.moduleUnitTester = &testRunner;
    }

private:
    RunTests runTests = RunTests.yes;
    TestMods testModsRun;
    TestMods testModsSkip;

    bool testRunner()
    {
        if (runTests == RunTests.no)
            return true;  // continue execution of main()

        size_t testCount;
        size_t failCount;
        Appender!(string[]) passedTests;

        /** Workaround: unittests are not sorted alphabetically */
        void function()[string] modToTest;

        foreach (m; ModuleInfo)
        {
            if (m is null)
                continue;

            if (auto fp = m.unitTest)
            {
                if (!m.name.startsWith("dtk"))
                    continue;  // only test dtk modules

                // run specific tests
                if (!testModsRun.empty && m.name !in testModsRun)
                    continue;

                // skip specific tests (overrides mods in testModsRun)
                if (!testModsSkip.empty && m.name in testModsSkip)
                    continue;

                testCount++;
                modToTest[m.name] = fp;
            }
        }

        if (!testModsRun.empty && !testCount)
        {
            writeln("- No tests found for:");
            foreach (testName; testModsRun.sortedElements)
                writefln("  + %s", testName);
        }

        if (!testCount)
            return true;  // continue execution of main() if no tests were found

        foreach (modName; modToTest.keys.sorted)
        {
            auto fp = modToTest[modName];

            try
            {
                stderr.writefln("  Testing: %s", modName);
                fp();
                passedTests ~= modName;
            }
            catch (Throwable e)
            {
                stderr.writeln();
                stderr.writeln(e);
                //~ /+ string path = format("\n%s%s%s", absPath("."), dirSep, e.file).normPath;
                //~ e.msg = format("%s(%s) : %s", path, e.line, e.msg); +/
                failCount++;
                throw e;
            }
        }

        if (testCount && !failCount)
        {
            writefln("\n- All tests pass (%s):", testCount);

            foreach (testName; passedTests.data)
                writefln("  + %s", testName);

            writeln();
        }

        // continue execution only if all tests passed
        return failCount == 0;
    }
}

