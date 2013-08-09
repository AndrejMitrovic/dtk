/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.radiobutton;

import std.conv;
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
        _varName = this.createVariableName();
        super(null, EmitGenericSignals.no);  // not an actual widget

        // tracer used instead of -command
        this.evalFmt(
            `
            proc tracer {varname args} {
                upvar #0 $varname var
                %s %s $var
            }
            `, _eventCallbackIdent, EventType.TkRadioButtonSelect);

        // hook up the tracer for this unique variable
        this.evalFmt(`trace add variable %s write "tracer %s"`, _varName, _varName);
    }

    /**
        Get the currently selected radio button value.
        It should equal to the $(D value) property of one of
        the radio buttons that are part of this radio group.
    */
    @property string value()
    {
        return to!string(Tcl_GetVar(App._interp, cast(char*)_varName.toStringz, 0));
    }

    /**
        Set the currently selected radio button value.
        It should equal to the $(D value) property of one of
        the radio buttons that are part of this radio group.
    */
    @property string value(string newValue)
    {
        return to!string(Tcl_SetVar(App._interp, cast(char*)_varName.toStringz, cast(char*)newValue.toStringz, 0));
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
    this(Widget master, RadioGroup radioGroup, string text, string value)
    {
        DtkOptions options;
        options["text"] = text;
        options["variable"] = radioGroup._varName;
        options["value"] = value;

        super(master, "ttk::radiobutton", options);

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
