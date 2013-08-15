/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.radiobutton;

import std.conv;
import std.exception;
import std.range;
import std.string;

import dtk.app;
import dtk.button;
import dtk.event;
import dtk.signals;
import dtk.types;
import dtk.utils;
import dtk.options;
import dtk.widget;

///
class RadioGroup : Widget
{
    // todo: this is not really a Widget, but it needs to have a callback mechanism
    this()
    {
        super(null, EmitGenericSignals.no);  // not an actual widget
        _varName = this.createTracedTaggedVariable(EventType.TkRadioButtonSelect);
    }

    /**
        Get the currently selected radio button value.
        It should equal to the $(D value) property of one of
        the radio buttons that are part of this radio group.
    */
    @property string value()
    {
        return this.getVar!string(_varName);
    }

    /**
        Set the currently selected radio button value.
        It should equal to the $(D value) property of one of
        the radio buttons that are part of this radio group.
    */
    @property void value(string newValue)
    {
        this.setVar(_varName, newValue);
    }

    private void add(RadioButton button)
    {
        if (_isEmpty)
        {
            _isEmpty = false;
            this.value = button.value;
        }
    }

private:
    string _varName;
    bool _isEmpty = true;
}

///
class RadioButton : Widget
{
    ///
    this(Widget master, RadioGroup radioGroup, string text, string value)
    {
        enforce(radioGroup !is null, "radioGroup argument must not be null.");

        DtkOptions options;
        options["text"] = text;
        options["variable"] = radioGroup._varName;
        options["value"] = value;

        super(master, TkType.radiobutton, options);

        // keyboard binding
        this.evalFmt("bind %s <Return> { %s invoke }", _name, _name);

        radioGroup.add(this);
        _radioGroup = radioGroup;
    }

    /** Return the value that's emitted when this radio button is selected. */
    @property string value()
    {
        return this.getOption!string("value");
    }

    /** Set the value that's emitted when this radio button is selected. */
    @property void value(string newValue)
    {
        auto oldValue = this.value;

        this.setOption("value", newValue);

        if (_radioGroup.value == oldValue)
            _radioGroup.value = newValue;
    }

    /** Select this radio button. */
    void select()
    {
        _radioGroup.value = this.value;
    }

    /** Get the current button style. */
    @property ButtonStyle style()
    {
        return this.getOption!string("style").toButtonStyle;
    }

    /** Set a new button style. */
    @property void style(ButtonStyle newStyle)
    {
        this.setOption("style", newStyle.toString);
    }

private:
    RadioGroup _radioGroup;
}
