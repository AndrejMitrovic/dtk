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

    assert(entry.validateMode == ValidateMode.none);

    entry.validateMode = ValidateMode.key;
    assert(entry.validateMode == ValidateMode.key);

    entry.value = "123";
    string curValue;

    size_t callCount;
    size_t expectedCallCount;

    entry.onEntryEvent ~= (scope EntryEvent event)
    {
        assert(event.value == curValue, format("%s != %s", event.value, curValue));
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
        //~ stderr.writefln("Validate event: %s", event);
        event.validated = all!isDigit(event.editValue);

        // onEntryEvent will be called
        if (event.validated)
        {
            curValue = event.newValue;
            ++expectedCallCount;
        }
    };

    assert(callCount == expectedCallCount, format("%s != %s", callCount, expectedCallCount));

    app.run();

    // test user input as well
    assert(callCount == expectedCallCount, format("%s != %s", callCount, expectedCallCount));
}

void main()
{
}
