/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.listbox;

import std.conv;
//~ import std.exception;
import std.range;
import std.string;
//~ import std.traits;
//~ import std.typetuple;

//~ import dtk.app;
//~ import dtk.button;
import dtk.event;
//~ import dtk.geometry;
//~ import dtk.signals;
//~ import dtk.types;
//~ import dtk.utils;
import dtk.options;
import dtk.widget;

///
enum SelectMode
{
    single,        ///
    multiple,      ///
    old_single,    /// deprecated
    old_multiple,  /// deprecated
}

// todo: could replace a tk::listbox with a simple ttk::treeview
///
class Listbox : Widget
{
    ///
    this(Widget master)
    {
        DtkOptions options;
        _varName = this.createVariableName();
        options["listvariable"] = _varName;
        super(master, TkType.listbox, options);

        string tracerFunc = format("tracer_%s", this.createCallbackName());

        // tracer used instead of -command
        this.evalFmt(
            `
            proc %s {varname args} {
                upvar #0 $varname var
                %s %s $var
            }
            `, tracerFunc, _eventCallbackIdent, EventType.TkListboxChange);

        // hook up the tracer for this unique variable
        this.evalFmt(`trace add variable %s write "%s %s"`, _varName, tracerFunc, _varName);
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

    /** Clear out all items in the listbox. */
    void clear()
    {
        values = [];
    }

    /** Get the current selection mode. */
    @property SelectMode selectMode()
    {
        return this.getOption!string("selectmode").toSelectMode();
    }

    /** Set the selection mode. */
    @property void selectMode(SelectMode newSelectMode)
    {
        return this.setOption("selectmode", newSelectMode.toString());
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

package SelectMode toSelectMode(string input)
{
    switch (input) with (SelectMode)
    {
        case "browse":     return single;
        case "extended":   return multiple;
        case "single":     return old_single;
        case "multiple":   return old_multiple;
        default:           assert(0, format("Unhandled select input: '%s'", input));
    }
}

package string toString(SelectMode selectMode)
{
    switch (selectMode) with (SelectMode)
    {
        case single:        return "browse";
        case multiple:      return "extended";
        case old_single:    return "single";
        case old_multiple:  return "multiple";
        default:            assert(0, format("Unhandled select mode: %s", selectMode));
    }
}
