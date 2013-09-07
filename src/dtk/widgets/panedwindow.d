/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.panedwindow;

import std.array;
import std.exception;
import std.range;
import std.string;

import dtk.geometry;
import dtk.interpreter;
import dtk.types;
import dtk.utils;

import dtk.widgets.widget;

///
class PanedWindow : Widget
{
    ///
    this(Widget master, Orientation orientation)
    {
        super(master, TkType.panedwindow, WidgetType.panedwindow);
        this.setOption("orient", to!string(orientation));
    }

    /** Get the orientation of this scrollbar. */
    @property Orientation orientation()
    {
        return this.getOption!Orientation("orient");
    }

    /** Set the orientation of this scrollbar. */
    @property void orientation(Orientation newOrient)
    {
        this.setOption("orient", newOrient);
    }

    /** Add a widget to this paned window. */
    void add(Widget widget, int weight = 0)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to add must be this paned window."));

        string weightStr = (weight == 0) ? "" : format("-weight %s", weight);
        tclEvalFmt("%s add %s %s", _name, widget._name, weightStr);
    }

    /** Insert a widget to this paned window at a specific position. */
    void insert(Widget widget, int index, int weight = 0)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to insert must be this paned window."));

        string weightStr = (weight == 0) ? "" : format("-weight %s", weight);
        tclEvalFmt("%s insert %s %s %s", _name, index, widget._name, weightStr);
    }

    /** Remove a widget from this paned window. */
    void remove(Widget widget)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to remove must be this paned window."));

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

    /** Set the width of a pane in this paned window. */
    void setWidth(Widget widget, int width)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to configure must be this paned window."));

        tclEvalFmt("%s pane %s -width %s", _name, widget._name, width);
    }

    /** ditto. */
    void setWidth(int index, int width)
    {
        tclEvalFmt("%s pane %s -width %s", _name, index, width);
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
}
