/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.combobox;

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
class Combobox : Widget
{
    ///
    this(Widget master)
    {
        DtkOptions options;
        _varName = this.createVariableName();
        options["textvariable"] = _varName;
        super(master, TkType.combobox, options);

        string tracerFunc = format("tracer_%s", this.createCallbackName());

        // tracer used instead of -command
        this.evalFmt(
            `
            proc %s {varname args} {
                upvar #0 $varname var
                %s %s $var
            }
            `, tracerFunc, _eventCallbackIdent, EventType.TkComboboxChange);

        // hook up the tracer for this unique variable
        this.evalFmt(`trace add variable %s write "%s %s"`, _varName, tracerFunc, _varName);
    }

    /** Get the currently selected combobox value. */
    @property string value()
    {
        return this.evalFmt("%s get", _name);
    }

    /** Set the combobox value. */
    @property void value(string newValue)
    {
        this.evalFmt("%s set %s", _name, newValue);
    }

    /** Get the values in this combobox. */
    @property string[] values()
    {
        return this.getOption!string("values").split(" ");
    }

    /** Set the values for this combobox. */
    @property void values(string[] newValues)
    {
        this.setOption("values", newValues.join(" "));
    }

    /** Allow or disallow inputting custom values to this combobox. */
    @property void readOnly(bool doDisableWrite)
    {
        this.setState(doDisableWrite ? "readonly" : "!readonly");
    }

private:
    string _varName;
}
