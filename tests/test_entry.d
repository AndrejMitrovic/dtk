module dtk.tests.test_entry;

import core.thread;

import std.ascii;
import std.algorithm;
import std.range;
import std.stdio;
import std.string;

import dtk;

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto entry = new Entry(testWindow);
    entry.pack();

    assert(entry.value.empty);
    entry.value = "foobar";
    assert(entry.value == "foobar");

    assert(entry.displayChar == ' ');
    entry.displayChar = '*';
    assert(entry.displayChar == '*');

    entry.resetDisplayChar();
    entry.value = "foo";
    entry.justification = Justification.right;

    assert(entry.validationMode == ValidationMode.none);

    entry.validationMode = ValidationMode.all;
    assert(entry.validationMode == ValidationMode.all);

    entry.value = "123";
    string curVal;

    size_t callCount;
    size_t expectedCallCount;

    entry.onEntryEvent ~= (scope EntryEvent event)
    {
        assert(event.value == curVal, format("%s != %s", event.value, curVal));
        assert(event.entry.value == curVal, format("%s != %s", event.entry.value, curVal));
        //~ stderr.writefln("Entry event: %s", event);
        ++callCount;
    };

    curVal = "123";
    entry.value = "123";
    ++expectedCallCount;

    curVal = "abc";
    entry.value = "abc";
    ++expectedCallCount;

    //~ entry.onValidateEvent ~= (scope ValidateEvent event)
    //~ {
        //~ event.validated = all!isDigit(event.changeValue);
    //~ }

    assert(callCount == expectedCallCount, format("%s != %s", callCount, expectedCallCount));

    app.run();
}

void main()
{
}
