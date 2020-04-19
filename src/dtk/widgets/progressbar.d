/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.progressbar;

import dtk.app;
import dtk.event;
import dtk.geometry;
import dtk.interpreter;
import dtk.types;
import dtk.utils;
import dtk.widgets.widget;

import std.conv;
import std.range;

///
enum ProgressMode
{
    determinate,    ///
    indeterminate,  ///
}

///
class Progressbar : Widget
{
    ///
    this(Widget parent, ProgressMode progressMode, Angle angle, int length, float maxValue = 100)
    {
        maxValue.checkFinite();
        super(parent, TkType.progressbar, WidgetType.progressbar);

        this.setOption("mode", to!string(progressMode));
        this.setOption("orient", to!string(angle));
        this.setOption("length", to!string(length));
        this.setOption("maximum", to!string(maxValue));

        _varName = makeVar();
        this.setOption("variable", _varName);
    }

    /** Get or set the angle of this progressbar. */
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
        Get or set the length of the long axis of the progress bar.
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

    /** Get or set the progress mode of this progressbar. */
    @property ProgressMode progressMode()
    {
        return this.getOption!ProgressMode("mode");
    }

    /** Ditto. */
    @property void progressMode(ProgressMode newProgressMode)
    {
        this.setOption("mode", newProgressMode);
    }

    /** Get or set the maximum value for this progresbar. */
    @property float maxValue()
    {
        return this.getOption!float("maximum");
    }

    /** Ditto. */
    @property void maxValue(float newMaxValue)
    {
        this.setOption("maximum", newMaxValue);
    }

    /**
        Get the current value of the progress bar.

        In determinate mode, this represents the amount of work completed.
        This is a value between 0.0 and maxValue set in
        the constructor.

        In indeterminate mode, it is interpreted modulo the maxValue.
        The progress bar completes one cycle when the value increases by maxValue.
    */
    @property float value()
    {
        string res = tclGetVar!string(_varName);

        if (res.empty)
            return 0.0;

        return to!float(res);
    }

    /**
        Set the current value of the progress bar.
        This should be a value between 0.0 and maxValue set in
        the constructor.
    */
    @property void value(float newValue)
    {
        newValue.checkFinite();
        tclSetVar(_varName, newValue);
    }

    /**
        If the scrollbar was constructed with
        indeterminate progress mode, this will
        begin the progress bar cycle.

        The progress bar will move its value every msecs.
    */
    void start(int msecs = 50)
    {
        tclEvalFmt("%s start %s", _name, msecs);
        _isRunning = true;
    }

    /**
        If the scrollbar was constructed with indeterminate
        progress mode, this will stop the progress bar cycle.

        $(RED Bugs:) Currently this function does not work
        inside of an event handler.
        See bug report: https://core.tcl.tk/tk/tktview/c597acdab39212f2b5557e69e38eb3191f4a5927

        Note: The bug was fixed in ttk-head.

        Todo: Provide ttk patches with dtk, or distribute latest
        ttk sources. Ttk is a source-only distribution (no binaries),
        so this should be easy.

        Todo2: Alternatively provide our own .tcl widgets we can use
        by distributing these files with fixes with dtk.
    */
    void stop()
    {
        tclEvalFmt("%s stop", _name);
        tclEval("update idletasks");
        _isRunning = false;
    }

    /**
        If the scrollbar was constructed with
        indeterminate progress mode, check if
        the progress bar is in motion.
    */
    @property bool isRunning()
    {
        return _isRunning;
    }

private:
    string _varName;
    bool _isRunning = false;
}
