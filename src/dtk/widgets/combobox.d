/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.combobox;

import std.exception;
import std.range;
import std.string;

import dtk.app;
import dtk.dispatch;
import dtk.event;
import dtk.interpreter;
import dtk.signals;
import dtk.types;
import dtk.utils;

import dtk.widgets.button;
import dtk.widgets.widget;

///
class Combobox : Widget
{
    ///
    this(Widget master)
    {
        super(master, TkType.combobox, WidgetType.combobox);

        string varName = makeVar();
        tclEvalFmt(`trace add variable %s write { %s %s %s }`, varName, _dtkCallbackIdent, EventType.combobox, _name);
        this.setOption("textvariable", varName);
    }

    /**
        Signal emitted when an item in the combobox is selected.
    */
    public Signal!ComboboxEvent onComboboxEvent;

    /** Get the currently selected combobox value. */
    @property string value()
    {
        return tclEvalFmt("%s get", _name);
    }

    /** Set the combobox value. */
    @property void value(string newValue)
    {
        tclEvalFmt("%s set %s", _name, newValue._tclEscape);
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
}
