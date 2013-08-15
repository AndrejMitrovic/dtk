/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.progressbar;

import std.conv;
import std.string;
import std.range;

import dtk.app;
import dtk.event;
import dtk.geometry;
import dtk.options;
import dtk.utils;
import dtk.widget;

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
    this(Widget master, Orientation orientation, int length, ProgressMode progressMode, float maxValue = 100)
    {
        DtkOptions options;
        options["orient"] = to!string(orientation);
        options["mode"] = to!string(progressMode);
        options["length"] = to!string(length);
        options["maximum"] = to!string(maxValue);

        _maxValue = maxValue;
        super(master, TkType.progressbar, options);

        _varName = this.createTracedTaggedVariable(EventType.TkProgressbarChange);
        this.setOption("variable", _varName);
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
        string res = this.getVar!string(_varName);

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
        this.setVar(_varName, newValue);
    }

    /** Get the maximum value that was set in the constructor. */
    @property float maxValue()
    {
        return _maxValue;
    }

    /**
        If the scrollbar was constructed with
        indeterminate progress mode, this will
        begin the progress bar cycle.

        The progress bar will move its value every msecs.
    */
    void start(int msecs = 50)
    {
        this.evalFmt("%s start %s", _name, msecs);
        _started = true;
    }

    /**
        If the scrollbar was constructed with indeterminate
        progress mode, this will stop the progress bar cycle.

        $(RED Bugs:) Currently this function does not work
        inside of an event handler.
        See bug report: https://core.tcl.tk/tk/tktview/c597acdab39212f2b5557e69e38eb3191f4a5927
    */
    void stop()
    {
        this.evalFmt("%s stop", _name);
        this.eval("update idletasks");
        _started = false;
    }

    /**
        If the scrollbar was constructed with
        indeterminate progress mode, check if
        the progress bar is in motion.
    */
    @property bool isRunning()
    {
        return _started;
    }

private:
    float _maxValue;
    string _varName;
    bool _started = false;
}
