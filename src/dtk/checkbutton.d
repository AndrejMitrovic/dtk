/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.checkbutton;

import std.conv;
import std.string;

import dtk.app;
import dtk.button;
import dtk.event;
import dtk.signals;
import dtk.utils;
import dtk.options;
import dtk.types;
import dtk.widget;

///
class CheckButton : Widget
{
    this(Widget master, string text)
    {
        DtkOptions options;
        options["text"] = text;
        _toggleVarName = this.createVariableName();
        options["variable"] = _toggleVarName;

        super(master, "ttk::checkbutton", options);

        this.toggleOff();

        // keyboard binding
        this.evalFmt("bind %s <Return> { %s invoke }", _name, _name);

        string tracerFunc = format("tracer_%s", this.createCallbackName());

        // tracer used instead of -command
        this.evalFmt(
            `
            proc %s {varname args} {
                upvar #0 $varname var
                %s %s $var
            }
            `, tracerFunc, _eventCallbackIdent, EventType.TkCheckButtonToggle);

        // hook up the tracer for this unique variable
        this.evalFmt(`trace add variable %s write "%s %s"`, _toggleVarName, tracerFunc, _toggleVarName);
    }

    /**
        Toggle the chekbutton to On. This will set its value to the
        value retrieived from onValue, and will emit an event
        with type TkButtonPush.
    */
    void toggleOn()
    {
        this.evalFmt("set %s %s", _toggleVarName, onValue());
    }

    /**
        Toggle the chekbutton to Off. This will set its value to the
        value retrieived from offValue, and will emit an event
        with type TkButtonPush.
    */
    void toggleOff()
    {
        this.evalFmt("set %s %s", _toggleVarName, offValue());
    }

    /**
        Toggle the checkbutton. An event with type TkButtonPush will be emitted.
    */
    void toggle()
    {
        this.evalFmt("%s invoke", _name);
    }

    /** Get the current state of the checkbutton. It should equal to either onValue or offValue. */
    string getValue()
    {
        return to!string(Tcl_GetVar(App._interp, cast(char*)_toggleVarName.toStringz, 0));
    }

    /** Return the value that's emitted when the check button is toggled on. */
    @property string onValue()
    {
        return this.getOption!string("onvalue");
    }

    /** Set the value that's emitted when the check button is toggled on. */
    @property void onValue(string newOnValue)
    {
        this.setOption("onvalue", newOnValue);
    }

    /** Return the value that's emitted when the check button is toggled off. */
    @property string offValue()
    {
        return this.getOption!string("offvalue");
    }

    /** Set the value that's emitted when the check button is toggled off. */
    @property void offValue(string newOffValue)
    {
        this.setOption("offvalue", newOffValue);
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
    string _toggleVarName;
}
