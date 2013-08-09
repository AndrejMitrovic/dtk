module test_radiobutton;

import core.thread;

import std.range;
import std.stdio;
import std.string;

import dtk;

void main()
{
    auto app = new App();

    auto radioGroup = new RadioGroup();
    auto radio1 = new RadioButton(app.mainWindow, radioGroup, "Set On", "on");
    auto radio2 = new RadioButton(app.mainWindow, radioGroup, "Set Off", "off");

    radio1.value = "on_value";
    radio2.value = "off_value";

    radioGroup.onEvent.connect(
    (Widget widget, Event event)
    {
        static size_t pressCount;

        switch (event.type) with (EventType)
        {
            case TkRadioButtonSelect:
                stderr.writefln("Radio button selected value: %s.", event.state);
                break;

            default:
        }
    });

    assert(radioGroup.value == radio1.value);

    radioGroup.value = radio2.value;
    assert(radioGroup.value == radio2.value);

    radio1.pack();
    radio2.pack();

    app.run();
}
