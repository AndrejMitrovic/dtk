/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.panedwindow;

import std.array;
import std.conv;
import std.exception;
import std.range;
import std.string;

import dtk.geometry;
import dtk.utils;
import dtk.options;
import dtk.widget;

///
class PanedWindow : Widget
{
    ///
    this(Widget master, Orientation orientation)
    {
        DtkOptions options;
        options["orient"] = to!string(orientation);
        super(master, TkType.panedwindow, options);
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
        this.evalFmt("%s add %s %s", _name, widget._name, weightStr);
    }

    /** Insert a widget to this paned window at a specific position. */
    void insert(Widget widget, int index, int weight = 0)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to insert must be this paned window."));

        string weightStr = (weight == 0) ? "" : format("-weight %s", weight);
        this.evalFmt("%s insert %s %s %s", _name, index, widget._name, weightStr);
    }

    /** Remove a widget from this paned window. */
    void remove(Widget widget)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to remove must be this paned window."));

        this.evalFmt("%s forget %s", _name, widget._name);
    }

    /** ditto. */
    void remove(int index)
    {
        this.evalFmt("%s forget %s", _name, index);
    }

    /** Note: disabled due to bugs */
    @disable void setPosition(int index, int newIndex)
    {
        import std.stdio;
        stderr.writeln("res: ", this.evalFmt("%s sashpos %s %s", _name, index, newIndex));
    }

    /** Set the width of a pane in this paned window. */
    void setWidth(Widget widget, int width)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to configure must be this paned window."));

        this.evalFmt("%s pane %s -width %s", _name, widget._name, width);
    }

    /** ditto. */
    void setWidth(int index, int width)
    {
        this.evalFmt("%s pane %s -width %s", _name, index, width);
    }

    /** Get all panes that are part of this paned window. */
    @property Widget[] panes()
    {
        string result = this.evalFmt("%s panes", _name);
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
