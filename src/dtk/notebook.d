/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.notebook;

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
enum TabState
{
    normal,
    disabled,
    hidden,
}

// todo: add these to add/insert methods.
// note: could use typeof(TabOptions.tupleof) in an argument list.
struct TabOptions
{
    string text;
    string image;  // todo: figure out the proper type later
    int compound;  // ditto
    int underline = -1;
    TabState tabState;
    Sticky sticky = Sticky.nsew;  // default is nsew
    Padding padding;

    string toString()
    {
        return format("-text %s %s %s %s -state %s -sticky %s -padding %s",
            text._enquote,
            "", // todo: image
            "", // todo: compound
            (underline == -1) ? "" : format("-underline %s", underline),
            tabState,
            sticky,
            padding.toString()._enquote);
    }
}

///
class Notebook : Widget
{
    ///
    this(Widget master)
    {
        super(master, TkType.notebook);
    }

    /** Add a widget to this notebook. */
    void add(Widget widget)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to add must be this notebook."));

        this.evalFmt("%s add %s", _name, widget._name);
    }

    /** ditto. */
    void add(Widget widget, string text)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to add must be this notebook."));

        string opts = format("-text %s", text._enquote);
        this.evalFmt("%s add %s %s", _name, widget._name, opts);
    }

    /** ditto. */
    void add(Widget widget, TabOptions tabOptions)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to add must be this notebook."));

        this.evalFmt("%s add %s %s", _name, widget._name, tabOptions.toString());
    }

    /** Insert a widget to this notebook at a specific position. */
    void insert(Widget widget, int index)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to insert must be this notebook."));

        this.evalFmt("%s insert %s %s", _name, index, widget._name);
    }

    /** ditto. */
    void insert(Widget widget, int index, string text)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to insert must be this notebook."));

        string opts = format("-text %s", text._enquote);
        this.evalFmt("%s insert %s %s %s", _name, index, widget._name, opts);
    }

    /** ditto. */
    void insert(Widget widget, int index, TabOptions tabOptions)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to insert must be this notebook."));

        this.evalFmt("%s insert %s %s %s", _name, index, widget._name, tabOptions.toString());
    }

    /** Remove a widget from this notebook. */
    void remove(Widget widget)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to remove must be this notebook."));

        this.evalFmt("%s forget %s", _name, widget._name);
    }

    /** ditto. */
    void remove(int index)
    {
        this.evalFmt("%s forget %s", _name, index);
    }

    /**
        Get the selected notebook tab.
        Note that by default the selected tab is the one which was first
        added via the add or insert calls, which is not necessarily the
        left-most tab.
    */
    @property Widget selected()
    {
        string widgetPath = this.evalFmt("%s select", _name);
        return cast(Widget)Widget.lookupWidgetPath(widgetPath);
    }

    /** Set the selected notebook tab. */
    @property void selected(Widget widget)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to select must be this notebook."));

        this.evalFmt("%s select %s", _name, widget._name);
    }

    /** ditto. */
    @property void selected(int index)
    {
        this.evalFmt("%s select %s", _name, index);
    }

    /** Hide a tab. */
    void hideTab(Widget widget)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to hide must be this notebook."));

        this.evalFmt("%s hide %s", _name, widget._name);
    }

    /** Un-hide a tab. */
    void unhideTab(Widget widget)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to un-hide must be this notebook."));

        this.add(widget);
    }

    /** Get the tab index of the widget. */
    int indexOf(Widget widget)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to get the index of must be this notebook."));

        return to!int(this.evalFmt("%s index %s", _name, widget._name));
    }

    /** Get the tab options for a widget. */
    @property TabOptions options(Widget widget)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to get the options from must be this notebook."));

        return _getTabOptions(widget._name);
    }

    /** ditto. */
    @property TabOptions options(int index)
    {
        return _getTabOptions(index);
    }

    // ident is either widget._name or an index
    private TabOptions _getTabOptions(T)(T ident)
    {
        TabOptions options;

        options.text = this.evalFmt("%s tab %s -text", _name, ident);
        // todo: image
        // todo: compound
        string underlineRes = this.evalFmt("%s tab %s -underline", _name, ident);
        options.underline = underlineRes.empty ? -1 : to!int(underlineRes);
        options.tabState = to!TabState(this.evalFmt("%s tab %s -state", _name, ident));
        options.sticky = toSticky(this.evalFmt("%s tab %s -sticky", _name, ident));
        options.padding = toPadding(this.evalFmt("%s tab %s -padding", _name, ident));

        return options;
    }

    /** Set the tab options for a widget. */
    void setOptions(Widget widget, TabOptions options)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget to set the options for must be this notebook."));

        //~ import std.stdio;
        //~ stderr.writefln("calling with: %s", options);
        //~ stderr.writefln("--result: %s", this.evalFmt("%s tab %s %s", _name, widget._name, options));
        this.evalFmt("%s tab %s %s", _name, widget._name, options);
    }

    /** ditto. */
    void setOptions(int index, TabOptions options)
    {
        this.evalFmt("%s tab %s %s", _name, index, options);
    }

    /** Get all widgets that are part of this notebook. */
    @property Widget[] tabs()
    {
        string result = this.evalFmt("%s tabs", _name);
        if (result.empty)
            return null;

        Appender!(Widget[]) tabs;

        foreach (widgetPath; result.splitter(" "))
        {
            auto widget = cast(Widget)Widget.lookupWidgetPath(widgetPath);
            if (widget !is null)
                tabs ~= widget;
        }

        return tabs.data;
    }
}
