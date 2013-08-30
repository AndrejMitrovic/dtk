/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.spinbox;

import std.conv;
import std.string;
import std.range;

import dtk.app;
import dtk.event;
import dtk.geometry;
import dtk.interpreter;
import dtk.options;
import dtk.utils;

import dtk.widgets.widget;

///
abstract class SpinboxBase : Widget
{
    ///
    package this(Widget master, DtkOptions options)
    {
        super(master, TkType.spinbox, options);

        _varName = this.createTracedTaggedVariable(TkEventType.TkSpinboxChange);
        this.setOption("textvariable", _varName);
    }

    /** Check the wrapping mode for this spinbox. */
    @property bool wrap()
    {
        return this.getOption!int("wrap") == 1;
    }

    /**
        Set the wrapping mode for this spinbox. If set to true,
        values will wrap around when the spinbox goes beyond the
        starting or ending value.
    */
    @property void wrap(bool doWrap)
    {
        this.setOption("wrap", doWrap ? 1 : 0);
    }

private:
    string _varName;
}

///
class ScalarSpinbox : SpinboxBase
{
    ///
    this(Widget master, float minValue = 0.0, float maxValue = 100.0)
    {
        DtkOptions options;
        options["from"] = to!string(minValue);
        options["to"] = to!string(maxValue);
        _minValue = minValue;
        _maxValue = maxValue;
        super(master, options);
    }

    /** Get the current value of the spinbox. */
    @property float value()
    {
        string res = tclGetVar!string(_varName);

        if (res.empty)
            return 0.0;

        return to!float(res);
    }

    /**
        Set the current value of the scale.
        This should be a value between minValue and maxValue set in
        the constructor.
    */
    @property void value(float newValue)
    {
        tclSetVar(_varName, newValue);
    }

    /** Get the minimum value that was set in the constructor. */
    @property float minValue()
    {
        return _minValue;
    }

    /** Get the maximum value that was set in the constructor. */
    @property float maxValue()
    {
        return _maxValue;
    }

private:
    float _minValue;
    float _maxValue;
}

///
class ListSpinbox : SpinboxBase
{
    ///
    this(Widget master, string[] values)
    {
        DtkOptions options;
        options["values"] = values.join(" ");
        super(master, options);
    }

    /** Get the values in this spinbox. */
    @property string[] values()
    {
        return this.getOption!string("values").split(" ");
    }

    /** Set the values in this spinbox. */
    @property void values(string[] newValues)
    {
        this.setOption("values", newValues.join(" "));
    }

    /** Get the current value of the spinbox. */
    @property string value()
    {
        return tclGetVar!string(_varName);
    }

    /**
        Set the current value of the spinbox.
    */
    @property void value(string newValue)
    {
        tclSetVar(_varName, newValue);
    }
}
