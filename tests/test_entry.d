module test_entry;

import core.thread;

import std.ascii;
import std.algorithm;
import std.range;
import std.stdio;
import std.string;

import dtk;

void main()
{
    auto app = new App();

    auto entry1 = new Entry(app.mainWindow);
    entry1.pack();

    assert(entry1.value.empty);
    entry1.value = "foobar";
    assert(entry1.value == "foobar");

    assert(entry1.displayChar == ' ');
    entry1.displayChar = '*';
    assert(entry1.displayChar == '*');

    entry1.resetDisplayChar();
    entry1.value = "foo";
    entry1.justification = Justification.right;

    assert(entry1.validationMode == ValidationMode.none);

    entry1.validationMode = ValidationMode.all;
    assert(entry1.validationMode == ValidationMode.all);

    entry1.value = "123";

    entry1.onValidation =
        (Widget widget, ValidateEvent event)
        {
            // only allow isDigit
            return all!isDigit(event.changeValue) ? IsValidated.yes : IsValidated.no;
        };

    entry1.onFailedValidation =
        (Widget widget, ValidateEvent event)
        {
            stderr.writeln(" -- FAILED VALIDATION --");
        };

    app.run();
}
