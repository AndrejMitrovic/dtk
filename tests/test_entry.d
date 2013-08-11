module test_entry;

import core.thread;

import std.range;
import std.stdio;
import std.string;

import dtk;

void main()
{
    auto app = new App();

    auto entry1 = new Entry(app.mainWindow);

    entry1.onEvent.connect(
    (Widget widget, Event event)
    {
        static size_t pressCount;

        switch (event.type) with (EventType)
        {
            case TkTextChange:
                stderr.writefln("Text change: %s.", event.state);
                entry1.setValidState(false);
                break;

            case TkValidate:
                stderr.writeln("Validating.");
                break;

            default:
        }

        //~ stderr.writefln("Event: %s", event);
    });

    entry1.pack();

    assert(entry1.value.empty);
    entry1.value = "foobar";
    assert(entry1.value == "foobar");

    assert(entry1.displayChar == ' ');
    entry1.displayChar = '*';
    assert(entry1.displayChar == '*');

    entry1.resetDisplayChar();
    entry1.value = "foo\nfoo bar\n foo bar doo";
    entry1.justification = Justification.right;

    assert(entry1.validationMode == ValidationMode.none);

    entry1.validationMode = ValidationMode.key;
    assert(entry1.validationMode == ValidationMode.key);

    entry1.value = "123";
    entry1.setValidator();

    app.run();
}
