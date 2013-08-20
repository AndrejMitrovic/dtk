/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.listbox;

import std.conv;
import std.range;
import std.string;

import dtk.event;
import dtk.options;
import dtk.utils;

import dtk.widgets.widget;

///
class Listbox : Widget
{
    // todo: could implelent a listbox with a ttk::treeview rather than tk::listbox

    ///
    this(Widget master)
    {
        super(master, TkType.listbox);

        _varName = this.createTracedTaggedVariable(EventType.TkListboxChange);
        this.setOption("listvariable", _varName);
    }

    /** Get the current list in the listbox. */
    @property string[] values()
    {
        return this.getVar!(string[])(_varName);
    }

    /** Set the list in the listbox. */
    @property void values(string[] newValues)
    {
        this.setVar(_varName, newValues);
    }

    /** Add an item to the end of the list. */
    void add(string value)
    {
        this.evalFmt("%s insert end %s", _name, value._enquote);
    }

    /** Clear out all items in the listbox. */
    void clear()
    {
        values = [];
    }

    /** Return the height of the listbox, in line count. */
    @property int height()
    {
        return this.getOption!int("height");
    }

    /**
        Set the height of the listbox, in line count.
        If the requested height is zero or less, the
        height for the listbox will be made large enough to
        hold all the values in the listbox.

        Note that the actual height may be scheduled to be
        updated at a later time, so .height may not reflect
        the new state immediately after it is set.
    */
    @property void height(int newHeight)
    {
        this.setOption("height", newHeight);
        this.eval("update idletasks");
    }

    /** Get the current selection mode. */
    @property SelectMode selectMode()
    {
        return this.getOption!string("selectmode").toSelectMode();
    }

    /** Set the selection mode. */
    @property void selectMode(SelectMode newSelectMode)
    {
        this.setOption("selectmode", newSelectMode.toString());
    }

    /** Get the indices of the selected items. */
    @property size_t[] selection()
    {
        string res = this.evalFmt("%s curselection", _name);
        if (res.empty)
            return [];

        return to!(size_t[])(res.split(" "));
    }

    /** Set a single selected item. This clears any previous selections. */
    @property void selection(size_t newIndex)
    {
        this.clearSelection();
        this.select(newIndex);
    }

    /** Set a number of selected indices. This clears any previous selections. */
    @property void selection(size_t[] newIndices)
    {
        this.clearSelection();
        foreach (index; newIndices)
            this.select(index);
    }

    /** Select a bounded range of items. This clears any previous selections. */
    void selectRange(size_t lowIdx, size_t highIdx)
    {
        this.clearSelection();
        this.evalFmt("%s selection set %s %s", _name, lowIdx, highIdx);
    }

    // select an item without clearing previous items.
    private void select(size_t index)
    {
        this.evalFmt("%s selection set %s", _name, index);
    }

    /** Clear any selections in the listbox. */
    void clearSelection()
    {
        this.evalFmt("%s selection clear 0 end", _name);
    }

private:
    string _varName;
}
