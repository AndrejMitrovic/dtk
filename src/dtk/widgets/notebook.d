/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.notebook;

import std.array;
import std.exception;
import std.range;

import dtk.geometry;
import dtk.image;
import dtk.interpreter;
import dtk.types;
import dtk.utils;

import dtk.widgets.options;
import dtk.widgets.widget;

///
enum TabState
{
    normal,
    disabled,
    hidden,
}

// todo: add these to add/insert methods.
// note: could use typeof(TabOptions.tupleof) in an argument list.
///
struct TabOptions
{
    string text;
    Image image;
    Compound compound;
    int underline = -1;
    TabState tabState;
    Sticky sticky = Sticky.nsew;  // default is nsew
    Padding padding;

    string toTclString()
    {
        return format("-text %s -image %s -compound %s %s -state %s -sticky %s -padding %s",
            text._tclEscape,
            image ? image._name : "{}",
            compound,
            (underline == -1) ? "" : format("-underline %s", underline),
            tabState,
            sticky,
            padding.toString()._tclEscape);
    }
}

///
class Notebook : Widget
{
    ///
    this(Widget master)
    {
        super(master, TkType.notebook, WidgetType.notebook);
    }

    /** Add a widget to this notebook. */
    void add(Widget widget)
    {
        _checkParent(widget);
        tclEvalFmt("%s add %s", _name, widget._name);
    }

    /** ditto. */
    void add(Widget widget, string text)
    {
        _checkParent(widget);
        string opts = format("-text %s", text._tclEscape);
        tclEvalFmt("%s add %s %s", _name, widget._name, opts);
    }

    /** ditto. */
    void add(Widget widget, TabOptions tabOptions)
    {
        _checkParent(widget);
        tclEvalFmt("%s add %s %s", _name, widget._name, tabOptions.toTclString());
    }

    /** Insert a widget to this notebook at a specific position. */
    void insert(Widget widget, int index)
    {
        _checkParent(widget);
        tclEvalFmt("%s insert %s %s", _name, index, widget._name);
    }

    /** ditto. */
    void insert(Widget widget, int index, string text)
    {
        _checkParent(widget);
        string opts = format("-text %s", text._tclEscape);
        tclEvalFmt("%s insert %s %s %s", _name, index, widget._name, opts);
    }

    /** ditto. */
    void insert(Widget widget, int index, TabOptions tabOptions)
    {
        _checkParent(widget);
        tclEvalFmt("%s insert %s %s %s", _name, index, widget._name, tabOptions.toTclString());
    }

    /** Remove a widget from this notebook. */
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

    /**
        Get the selected notebook tab.
        Note that by default the selected tab is the one which was first
        added via the add or insert calls, which is not necessarily the
        left-most tab.
    */
    @property Widget selected()
    {
        string widgetPath = tclEvalFmt("%s select", _name);
        return cast(Widget)Widget.lookupWidgetPath(widgetPath);
    }

    /** Set the selected notebook tab. */
    @property void selected(Widget widget)
    {
        _checkParent(widget);
        tclEvalFmt("%s select %s", _name, widget._name);
    }

    /** ditto. */
    @property void selected(int index)
    {
        tclEvalFmt("%s select %s", _name, index);
    }

    /** Hide a tab. */
    void hideTab(Widget widget)
    {
        _checkParent(widget);
        tclEvalFmt("%s hide %s", _name, widget._name);
    }

    /** Un-hide a tab. */
    void unhideTab(Widget widget)
    {
        _checkParent(widget);
        this.add(widget);
    }

    /** Get the tab index of the widget. */
    int indexOf(Widget widget)
    {
        _checkParent(widget);
        return to!int(tclEvalFmt("%s index %s", _name, widget._name));
    }

    /** Get the tab options for a widget. */
    TabOptions options(Widget widget)
    {
        _checkParent(widget);
        return _getTabOptions(widget._name);
    }

    /** ditto. */
    TabOptions options(int index)
    {
        return _getTabOptions(index);
    }

    // ident is either widget._name or an index
    private TabOptions _getTabOptions(T)(T ident)
    {
        TabOptions options;

        options.text = tclEvalFmt("%s tab %s -text", _name, ident);

        string underlineRes = tclEvalFmt("%s tab %s -underline", _name, ident);
        options.underline = underlineRes.empty ? -1 : to!int(underlineRes);

        options.tabState = to!TabState(tclEvalFmt("%s tab %s -state", _name, ident));
        options.sticky = toSticky(tclEvalFmt("%s tab %s -sticky", _name, ident));
        options.padding = toPadding(tclEvalFmt("%s tab %s -padding", _name, ident));
        options.compound = to!Compound(tclEvalFmt("%s tab %s -compound", _name, ident));

        string imagePath = tclEvalFmt("%s tab %s -image", _name, ident);
        options.image = cast(Image)Widget.lookupWidgetPath(imagePath);

        return options;
    }

    /** Set the tab options for a widget. */
    void setOptions(Widget widget, TabOptions options)
    {
        _checkParent(widget);
        tclEvalFmt("%s tab %s %s", _name, widget._name, options.toTclString());
    }

    /** ditto. */
    void setOptions(int index, TabOptions options)
    {
        tclEvalFmt("%s tab %s %s", _name, index, options.toTclString());
    }

    /** Get all widgets that are part of this notebook. */
    @property Widget[] tabs()
    {
        string result = tclEvalFmt("%s tabs", _name);
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

private:

    private void _checkParent(Widget widget)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of passed widget this notebook widget."));
    }
}
