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

///
struct Tab
{
    /** Hide this tab. */
    void hide()
    {
        tclEvalFmt("%s hide %s", _book._name, _tabName);
    }

    /** Un-hide this tab. */
    void show()
    {
        _book._add(_tabName);
    }

    /** Get the index of this tab. */
    int index()
    {
        return to!int(tclEvalFmt("%s index %s", _book._name, _tabName));
    }

    /** Select this tab. */
    void select()
    {
        tclEvalFmt("%s select %s", _book._name, _tabName);
    }

    /** Remove this tab. */
    void remove()
    {
        _book._remove(_tabName);
    }

    @property string text()
    {
        return tclEvalFmt("%s tab %s -text", _book._name, _tabName);
    }

    @property void text(string newText)
    {
        tclEvalFmt("%s tab %s -text %s", _book._name, _tabName, newText._tclEscape);
    }

    @property Image image()
    {
        string imagePath = tclEvalFmt("%s tab %s -image", _book._name, _tabName);
        return cast(Image)Widget.lookupWidgetPath(imagePath);
    }

    @property void image(Image newImage)
    {
        tclEvalFmt("%s tab %s -image %s", _book._name, _tabName, newImage ? newImage._name : "{}");
    }

    @property Compound compound()
    {
        return to!Compound(tclEvalFmt("%s tab %s -compound", _book._name, _tabName));
    }

    @property void compound(Compound newCompound)
    {
        tclEvalFmt("%s tab %s -compound %s", _book._name, _tabName, newCompound);
    }

    @property int underline()
    {
        return to!int(tclEvalFmt("%s tab %s -underline", _book._name, _tabName));
    }

    @property void underline(int newUnderline)
    {
        tclEvalFmt("%s tab %s -underline %s", _book._name, _tabName, newUnderline);
    }

    @property TabState tabState()
    {
        return to!TabState(tclEvalFmt("%s tab %s -state", _book._name, _tabName));
    }

    @property void tabState(TabState newTabState)
    {
        tclEvalFmt("%s tab %s -state %s", _book._name, _tabName, newTabState);
    }

    @property Sticky sticky()
    {
        return toSticky(tclEvalFmt("%s tab %s -sticky", _book._name, _tabName));
    }

    @property void sticky(Sticky newSticky)
    {
        tclEvalFmt("%s tab %s -sticky %s", _book._name, _tabName, newSticky);
    }

    @property Padding padding()
    {
        return toPadding(tclEvalFmt("%s tab %s -padding", _book._name, _tabName));
    }

    @property void padding(Padding newPadding)
    {
        tclEvalFmt("%s tab %s -padding %s", _book._name, _tabName, newPadding.toString()._tclEscape);
    }

private:
    Notebook _book;
    string _tabName;
}

///
class Notebook : Widget
{
    ///
    this(Widget parent)
    {
        super(parent, TkType.notebook, WidgetType.notebook);
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
        tclEvalFmt("%s add %s -text %s", _name, widget._name, text._tclEscape);
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

    /** Remove all widgets from this notebook. */
    void clear()
    {
        string result = tclEvalFmt("%s tabs", _name);
        foreach (widgetName; result.splitter(" "))
            tclEvalFmt("%s forget %s", _name, widgetName);
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

    /** Get the tab options for a widget. */
    Tab opIndex(Widget widget)
    {
        _checkParent(widget);
        return Tab(this, widget._name);
    }

    /** ditto. */
    Tab opIndex(int index)
    {
        enforce(index < length);
        return Tab(this, to!string(index));
    }

    /** Get the number of tabs. */
    @property int length()
    {
        return to!int(tclEvalFmt("%s index end", _name));
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

    // for unhiding
    private void _add(string path)
    {
        tclEvalFmt("%s add %s", _name, path);
    }

    private void _remove(string pathName)
    {
        tclEvalFmt("%s forget %s", _name, pathName);
    }

    private void _checkParent(Widget widget)
    {
        enforce(widget.parentWidget is this,
            format("The parent widget of the widget argument must be this notebook widget."));
    }
}
