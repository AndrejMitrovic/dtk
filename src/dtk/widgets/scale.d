/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.scale;

import std.string;
import std.range;

import dtk.app;
import dtk.event;
import dtk.interpreter;
import dtk.geometry;
import dtk.types;
import dtk.utils;

import dtk.widgets.widget;

///
class Scale : Widget
{
    ///
    this(Widget master, Orientation orientation, int length, float minValue = 0.0, float maxValue = 100.0)
    {
        _minValue = minValue;
        _maxValue = maxValue;
        super(master, TkType.scale, WidgetType.scale);

        this.setOption("orient", to!string(orientation));
        this.setOption("length", to!string(length));
        this.setOption("from", to!string(minValue));
        this.setOption("to", to!string(maxValue));

        _varName = makeTracedVar(TkEventType.TkScaleChange);
        this.setOption("variable", _varName);
    }

    /** Get the current value of the scale. */
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
    string _varName;
}
