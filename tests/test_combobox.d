module test_combobox;

import core.thread;

import std.range;
import std.stdio;
import std.string;

import dtk;

void main()
{
    auto app = new App();

    auto box1 = new Combobox(app.mainWindow);

    box1.onEvent.connect(
    (Widget widget, Event event)
    {
        switch (event.type) with (EventType)
        {
            case TkComboboxChange:
                stderr.writefln("Combobox changed value to: %s.", (cast(Combobox)widget).value);
                break;

            default:
        }

        //~ stderr.writefln("Event: %s", event);
    });

    assert(box1.value.empty);

    box1.value = "foobar";
    assert(box1.value == "foobar");

    assert(box1.values.empty);
    box1.values = ["foo", "bar", "foobar"];

    box1.readOnly = true;
    box1.readOnly = false;

    box1.pack();
    app.run();
}
