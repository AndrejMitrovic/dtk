/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.pane;

import dtk.geometry;
import dtk.imports;
import dtk.interpreter;
import dtk.types;
import dtk.utils;

import dtk.widgets.widget;

///
class Pane : Widget
{
    ///
    this(Widget parent, Angle angle)
    {
        string extraOpts = format("-orient %s", to!string(angle));
        super(parent, TkType.panedwindow, WidgetType.pane, extraOpts);
    }

    /**
        Get the angle of this scrollbar.
        The angle cannot be changed once initially set.
    */
    @property Angle angle()
    {
        return this.getOption!Angle("orient");
    }

    /** Add a widget to this paned window. */
    void add(Widget widget, int weight = 0)
    {
        _checkParent(widget);
        string weightStr = (weight == 0) ? "" : format("-weight %s", weight);
        tclEvalFmt("%s add %s %s", _name, widget._name, weightStr);
    }

    /** Insert a widget to this paned window at a specific position. */
    void insert(Widget widget, int index, int weight = 0)
    {
        _checkParent(widget);
        string weightStr = (weight == 0) ? "" : format("-weight %s", weight);
        tclEvalFmt("%s insert %s %s %s", _name, index, widget._name, weightStr);
    }

    /** Remove a widget from this paned window. */
    void remove(Widget widget)
    {
        _checkParent(widget);
        tclEvalFmt("%s forget %s", _name, widget._name);
    }

    /** ditto. */
    void remove(int index)
    {
        tclEvalFmt("%s forget %s", _name, index);
    }

    /** Note: disabled due to bugs */
    @disable void setPosition(int index, int newIndex)
    {
        tclEvalFmt("%s sashpos %s %s", _name, index, newIndex);
    }

    /**
        An integer specifying the relative stretchability of the pane.
        When the paned window is resized, the extra space is added or
        subtracted to each pane proportionally to its weight.
    */
    void setWeight(Widget widget, int weight)
    {
        _checkParent(widget);
        tclEvalFmt("%s pane %s -weight %s", _name, widget._name, weight);
    }

    /** ditto. */
    void setWeight(int index, int weight)
    {
        tclEvalFmt("%s pane %s -weight %s", _name, index, weight);
    }

    /**
        Get the weight of a paned widget.
    */
    int getWeight(Widget widget)
    {
        return to!int(tclEvalFmt("%s pane %s -weight", _name, widget._name));
    }

    /** ditto. */
    int getWeight(int index)
    {
        return to!int(tclEvalFmt("%s pane %s -weight", _name, index));
    }

    /** Get all widgets that are part of this paned window. */
    @property Widget[] panes()
    {
        string result = tclEvalFmt("%s panes", _name);
        if (result.empty)
            return null;

        Appender!(Widget[]) panes;

        foreach (widgetPath; result.splitter(" "))
        {
            auto widget = cast(Widget)Widget.lookupWidgetPath(widgetPath);
            if (widget !is null)
                panes ~= widget;
        }

        return panes.data;
    }

private:

    private void _checkParent(Widget widget)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget argument must be this paned window."));
    }
}
