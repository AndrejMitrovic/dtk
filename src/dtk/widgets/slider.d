/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.slider;

import dtk.app;
import dtk.dispatch;
import dtk.event;
import dtk.geometry;
import dtk.interpreter;
import dtk.signals;
import dtk.types;
import dtk.utils;
import dtk.widgets.widget;

import std.algorithm;
import std.conv;
import std.range;

///
class Slider : Widget
{
    ///
    this(Widget parent, Angle angle, int length, float minValue = 0.0, float maxValue = 100.0)
    {
        minValue.checkFinite();
        maxValue.checkFinite();
        super(parent, TkType.scale, WidgetType.slider);

        this.setOption("orient", to!string(angle));
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

    /** Get or set the angle of this slider. */
    @property Angle angle()
    {
        return this.getOption!Angle("orient");
    }

    /** Ditto. */
    @property void angle(Angle newOrient)
    {
        this.setOption("orient", newOrient);
    }

    /**
        Get or set the length of the long axis of the slider bar.
        This is its width if angle is horizontal,
        or height if angle is vertical.
    */
    @property int length()
    {
        return this.getOption!int("length");
    }

    /** Ditto. */
    @property void length(int newLength)
    {
        this.setOption("length", newLength);
    }

    /** Get or set the minimum value of this slider. */
    @property float minValue()
    {
        return this.getOption!float("from");
    }

    /** Ditto. */
    @property void minValue(float newMinValue)
    {
        newMinValue.checkFinite();
        this.setOption("from", newMinValue);
    }

    /** Get or set the maximum value of this slider. */
    @property float maxValue()
    {
        return this.getOption!float("to");
    }

    /** Ditto. */
    @property void maxValue(float newMaxValue)
    {
        newMaxValue.checkFinite();
        this.setOption("to", newMaxValue);
    }

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
        The value will be clipped between minValue and maxValue.
    */
    @property void value(float newValue)
    {
        newValue.checkFinite();
        newValue = min(newValue, maxValue).max(newValue, minValue);
        tclSetVar(_varName, newValue);
    }

private:
    string _varName;
}
