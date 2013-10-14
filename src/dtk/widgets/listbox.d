/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.listbox;

import dtk.dispatch;
import dtk.event;
import dtk.signals;
import dtk.imports;
import dtk.interpreter;
import dtk.types;
import dtk.utils;

import dtk.widgets.options;
import dtk.widgets.widget;

///
class Listbox : Widget
{
    // todo: could implelent a listbox with a ttk::treeview rather than tk::listbox

    ///
    this(Widget parent)
    {
        super(parent, TkType.listbox, WidgetType.listbox);

        _varName = makeVar();
        tclEvalFmt(`trace add variable %s write { %s %s %s %s }`, _varName, _dtkCallbackIdent, EventType.listbox, _name, ListboxAction.edit);
        this.setOption("listvariable", _varName);
    }

    /**
        Signal emitted when one or more items in the listbox are selected.
    */
    public Signal!ListboxEvent onListboxEvent;

    /** Get the current list in the listbox. */
    @property string[] values()
    {
        return tclGetVar!(string[])(_varName);
    }

    /** Set the list in the listbox. */
    @property void values(string[] newValues)
    {
        tclSetVar(_varName, newValues);
    }

    /** Add an item to the end of the list. */
    void add(string value)
    {
        tclEvalFmt("%s insert end %s", _name, value._tclEscape);
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
        tclEval("update idletasks");
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
        string res = tclEvalFmt("%s curselection", _name);
        if (res.empty)
            return [];

        return to!(size_t[])(res.split(" "));
    }

    /** Set a single selected item. This clears any previous selections. */
    @property void selection(size_t newIndex)
    {
        _selectNone();
        _select(newIndex);
        _emitSelectEvent();
    }

    /** Set a number of selected indices. This clears any previous selections. */
    @property void selection(size_t[] newIndices)
    {
        _selectNone();
        foreach (index; newIndices)
            _select(index);

        _emitSelectEvent();
    }

    /**
        Select a bounded range of items. This clears any previous selections.
        $(D highIdx) is inclusive, meaning $(D selectRange(0, 2)) will select
        items at indices 0 and 2.
    */
    void selectRange(size_t lowIdx, size_t highIdx)
    {
        _selectNone();
        tclEvalFmt("%s selection set %s %s", _name, lowIdx, highIdx);
        _emitSelectEvent();
    }

    /** Clear any selections in the listbox. */
    void clearSelection()
    {
        _selectNone();
        _emitSelectEvent();
    }

    /** Get the list of selected items in the listbox. */
    @property string[] selectedValues()
    {
        string res = tclEvalFmt("%s curselection", _name);
        if (res.empty)
            return [];

        string[] values = tclGetVar!(string[])(_varName);

        Appender!(string[]) result;

        auto indices = to!(size_t[])(res.split(" "));
        foreach (index; indices)
            result ~= values[index];

        return result.data;
    }

    // select an item without clearing previous items.
    private void _select(size_t index)
    {
        tclEvalFmt("%s selection set %s", _name, index);
    }

    // clear all selections
    private void _selectNone()
    {
        tclEvalFmt("%s selection clear 0 end", _name);
    }

    // select event is not implicitly generated in Tk when calling API functions.
    private void _emitSelectEvent()
    {
        tclEvalFmt("event generate %s <<ListboxSelect>>", _name);
    }

private:
    string _varName;
}
