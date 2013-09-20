/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.slider;

import std.algorithm;
import std.string;
import std.range;

import dtk.app;
import dtk.dispatch;
import dtk.event;
import dtk.geometry;
import dtk.interpreter;
import dtk.signals;
import dtk.types;
import dtk.utils;

import dtk.widgets.widget;

///
class Slider : Widget
{
    ///
    this(Widget master, Orientation orientation, int length, float minValue = 0.0, float maxValue = 100.0)
    {
        _minValue = minValue;
        _maxValue = maxValue;
        super(master, TkType.scale, WidgetType.slider);

        this.setOption("orient", to!string(orientation));
        this.setOption("length", to!string(length));
        this.setOption("from", to!string(minValue));
        this.setOption("to", to!string(maxValue));

        _varName = makeVar();
        tclEvalFmt(`trace add variable %s write { %s %s %s }`, _varName, _dtkCallbackIdent, EventType.slider, _name);
        this.setOption("variable", _varName);
    }

    /**
        Signal emitted when the slider value changes.
    */
    public Signal!SliderEvent onSliderEvent;

    /** Get the current value of the slider. */
    @property float value()
    {
        string res = tclGetVar!string(_varName);

        if (res.empty)
            return 0.0;

        return to!float(res);
    }

    /**
        Set the current value of the slider.
        The value will be clipped between minValue and maxValue set
        in the constructor.
    */
    @property void value(float newValue)
    {
        newValue = min(newValue, _maxValue).max(newValue, _minValue);
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
