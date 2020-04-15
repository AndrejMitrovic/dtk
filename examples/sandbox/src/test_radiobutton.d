/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.test_radiobutton;

import core.thread;

import std.range;
import std.stdio;
import std.string;

import dtk;

unittest
{
    auto app = new App;
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    // todo: radiogroup should take a list of radio buttons instead of passing it like this
    auto radioGroup = new RadioGroup(testWindow);
    auto radio1 = new RadioButton(radioGroup, "Set On", "on");
    auto radio2 = new RadioButton(radioGroup, "Set Off", "off");
    auto radio3 = new RadioButton(radioGroup, "Set No", "invalid");

    radio1.value = "on_value";
    radio2.value = "off_value";

    radioGroup.pack();
    radio1.pack();
    radio2.pack();
    radio3.pack();

    assert(radioGroup.selectedValue == radio1.value, format("%s != %s", radioGroup.selectedValue, radio1.value));
    assert(radioGroup.selectedButton is radio1);

    radioGroup.selectedValue = radio2.value;
    assert(radioGroup.selectedValue == radio2.value);
    assert(radioGroup.selectedButton is radio2);

    radio1.select();
    assert(radioGroup.selectedValue == radio1.value);
    assert(radioGroup.selectedButton is radio1);

    radio2.select();
    assert(radioGroup.selectedValue == radio2.value);
    assert(radioGroup.selectedButton is radio2);

    radio2.value = "changed value";
    assert(radioGroup.selectedValue == radio2.value);
    assert(radioGroup.selectedButton is radio2);

    assert(radio1.textWidth == 0);  // natural width
    radio1.textWidth = -50;  // set minimum 50 units
    assert(radio1.textWidth == -50);

    radio1.textWidth = 0;
    assert(radio1.textWidth == 0);

    radio1.textWidth = 50;   // set maximum 50 units
    assert(radio1.textWidth == 50);

    RadioButton selectedButton;

    size_t callCount;
    size_t expectedCallCount;

    radioGroup.onRadioButtonEvent ~= (scope RadioButtonEvent event)
    {
        assert(event.radioGroup.selectedButton == selectedButton);
        assert(event.radioGroup.selectedValue == selectedButton.value);

        if (event.radioGroup.selectedButton is radio1)
            radio3.disable();
        else
            radio3.enable();

        ++callCount;
    };

    selectedButton = radio1;
    radioGroup.selectedButton = selectedButton;
    ++expectedCallCount;

    selectedButton = radio3;
    radioGroup.selectedButton = selectedButton;
    ++expectedCallCount;

    assert(callCount == expectedCallCount, format("%s != %s", callCount, expectedCallCount));

    app.run();
}

void main()
{
}
