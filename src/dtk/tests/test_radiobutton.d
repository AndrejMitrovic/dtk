module dtk.tests.test_radiobutton;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.range;
import std.stdio;
import std.string;

static if (__VERSION__ < 2064)
    import dtk.all;
else
    import dtk;

import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    // todo: radiogroup should take a list of radio buttons instead of passing it like this
    auto radioGroup = new RadioGroup();
    auto radio1 = new RadioButton(testWindow, radioGroup, "Set On", "on");
    auto radio2 = new RadioButton(testWindow, radioGroup, "Set Off", "off");
    auto radio3 = new RadioButton(testWindow, radioGroup, "Set No", "invalid");

    radio1.value = "on_value";
    radio2.value = "off_value";

    radioGroup.onEvent.connect(
    (Widget widget, Event event)
    {
        static size_t pressCount;

        switch (event.type) with (EventType)
        {
            case TkRadioButtonSelect:
                logf("Radio button selected value: %s.", event.state);

                if (event.state == radio1.value)
                    radio3.enable();

                // just to try things out
                if (event.state == radio2.value)
                    radio3.disable();

                break;

            default:
        }
    });

    assert(radioGroup.value == radio1.value);

    radioGroup.value = radio2.value;
    assert(radioGroup.value == radio2.value);

    radio1.select();
    assert(radioGroup.value == radio1.value);

    radio2.select();
    assert(radioGroup.value == radio2.value);

    radio1.pack();
    radio2.pack();
    radio3.pack();

    app.testRun();
}
