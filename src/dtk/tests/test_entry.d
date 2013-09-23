/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.test_entry;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.ascii;
import std.algorithm;
import std.range;
import std.stdio;
import std.string;

import dtk;

import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto entry = new Entry(testWindow);
    entry.pack();

    assert(entry.value.empty);
    entry.value = "foo bar";
    assert(entry.value == "foo bar");

    assert(entry.displayChar == ' ');
    entry.displayChar = '*';
    assert(entry.displayChar == '*');

    entry.resetDisplayChar();
    entry.value = "foo";
    entry.justification = Justification.right;

    assert(entry.validateMode == ValidateMode.none);

    entry.validateMode = ValidateMode.all;
    assert(entry.validateMode == ValidateMode.all);

    entry.value = "123";
    string curValue;

    size_t callCount;
    size_t expectedCallCount;

    entry.onKeyboardEvent ~= (scope Event event)
    {
        ++callCount;
    };

    entry.onEntryEvent ~= (scope EntryEvent event)
    {
        assert(event.entry.value == curValue, format("%s != %s", event.entry.value, curValue));
        ++callCount;
    };

    curValue = "123";
    entry.value = "123";
    ++expectedCallCount;

    curValue = "abc";
    entry.value = "abc";
    ++expectedCallCount;

    entry.onValidateEvent ~= (scope ValidateEvent event)
    {
        // always allow removal
        if (event.action == ValidateAction.remove)
        {
            event.validated = true;
            return;
        }
        else
        if (event.action == ValidateAction.insert)
        {
            // only allow new digits in
            event.validated = all!isDigit(event.editValue);

            // onEntryEvent will be called
            if (event.validated)
                curValue = event.newValue;

            ++callCount;
        }
    };

    assert(callCount == expectedCallCount, format("%s != %s", callCount, expectedCallCount));

    app.testRun();
}
