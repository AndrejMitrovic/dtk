/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.menu;

import std.conv;
import std.exception;
import std.range;
import std.string;

import dtk.app;
import dtk.event;
import dtk.options;
import dtk.types;
import dtk.utils;
import dtk.widget;
import dtk.window;

/// Common code for menu bars and menus
abstract class MenuClass : Widget
{
    this(InitLater initLater)
    {
        super(initLater);
    }

    /** A menu must always have a parent, so proper initialization is required. */
    package void initParent(Widget master)
    {
        DtkOptions options;
        options["tearoff"] = "0";  // disable tearoff by default
        this.initialize(master, TkType.menu, options, EmitGenericSignals.no);
    }

    /** Add a menu to this menu. */
    final void addMenu(Menu menu)
    {
        assert(!_name.empty);
        menu.initParent(this);
        this.evalFmt("%s add cascade -menu %s -label %s", _name, menu._name, menu._label._enquote);
    }

    /** Insert a menu at a specific position. */
    final void insertMenu(Menu menu, int index)
    {
        assert(!_name.empty);
        menu.initParent(this);
        this.evalFmt("%s insert %s cascade -menu %s -label %s", _name, index, menu._name, menu._label._enquote);
    }

    /** Add an item to this menu. */
    final void addItem(MenuItem menuItem)
    {
        assert(!_name.empty);
        this.evalFmt("%s add command -label %s -command { %s %s }", _name, menuItem._label, menuItem._eventCallbackIdent, EventType.TkMenuItemSelect);
    }

    /** Insert an item at a specific position. */
    final void insertItem(MenuItem menuItem, int index)
    {
        assert(!_name.empty);
        this.evalFmt("%s insert %s command -label %s -command { %s %s }", _name, index, menuItem._label._enquote, menuItem._eventCallbackIdent, EventType.TkMenuItemSelect);
    }

    /** Add a check menu item to this menu. */
    final void addItem(CheckMenuItem menuItem)
    {
        assert(!_name.empty);
        this.evalFmt("%s add checkbutton -label %s -variable %s -onvalue %s -offvalue %s", _name, menuItem._label._enquote, menuItem._toggleVarName, menuItem._onValue._enquote, menuItem._offValue._enquote);
    }

    /** Insert a check menu item at a specific position. */
    final void insertItem(CheckMenuItem menuItem, int index)
    {
        assert(!_name.empty);
        this.evalFmt("%s insert %s checkbutton -label %s -variable %s -onvalue %s -offvalue %s", _name, index, menuItem._label._enquote, menuItem._toggleVarName, menuItem._onValue._enquote, menuItem._offValue._enquote);
    }

    /** Add a radio menu group to this menu. */
    final void addItem(RadioGroupMenu menuItem)
    {
        assert(!_name.empty);

        foreach (radioMenuItem; menuItem.items)
        {
            this.evalFmt("%s add radiobutton -label %s -variable %s -value %s",
                _name, radioMenuItem._label._enquote, menuItem._varName, radioMenuItem._value);
        }
    }

    /** Insert a radio menu group at a specific position. */
    final void insertItem(RadioGroupMenu menuItem, int index)
    {
        assert(!_name.empty);

        foreach (radioMenuItem; menuItem.items)
        {
            this.evalFmt("%s insert %s radiobutton -label %s -variable %s -value %s",
                _name, index++, radioMenuItem._label._enquote, menuItem._varName, radioMenuItem._value);
        }
    }
}

///
class MenuBar : MenuClass
{
    this()
    {
        super(InitLater.init);
    }
}

///
class Menu : MenuClass
{
    ///
    this(string label)
    {
        _label = label;
        super(InitLater.init);
    }

    /** Add a dividing line. */
    final void addSeparator()
    {
        this.evalFmt("%s add separator", _name);
    }

    /** Insert a dividing line at a specific position. */
    final void insertSeparator(int index)
    {
        this.evalFmt("%s insert %s separator", _name, index);
    }

    /** Get the menu label. */
    @property string label()
    {
        return _label;
    }

private:
    string _label;
}

///
class MenuItem : Widget
{
    ///
    this(string label)
    {
        _label = label;
        super(CreateFakeWidget.init);
    }

    /** Get the menu item label. */
    @property string label()
    {
        return _label;
    }

private:
    string _label;
}

///
class CheckMenuItem : Widget
{
    ///
    this(string label, string onValue = "0", string offValue = "1")
    {
        _label = label;
        _onValue = onValue;
        _offValue = offValue;
        super(CreateFakeWidget.init);
        _toggleVarName = this.createTracedTaggedVariable(EventType.TkCheckMenuItemToggle);
    }

    /** Get the menu item label. */
    @property string label()
    {
        return _label;
    }

    /** Get the current state of the checkbutton. It should equal to either onValue or offValue. */
    @property string value()
    {
        return to!string(Tcl_GetVar(App._interp, cast(char*)_toggleVarName.toStringz, 0));
    }

private:
    string _label;
    string _toggleVarName;
    string _onValue;
    string _offValue;
}

///
class RadioGroupMenu : Widget
{
    // todo: this is not really a Widget, but it needs to have a callback mechanism
    this()
    {
        super(CreateFakeWidget.init);
        _varName = this.createTracedTaggedVariable(EventType.TkRadioMenuSelect);
    }

    /**
        Get the currently selected radio menu value.
        It should equal to the $(D value) property of one of
        the radio menus that are part of this radio group.
    */
    @property string value()
    {
        return this.getVar!string(_varName);
    }

    /**
        Set the currently selected radio menu value.
        It should equal to the $(D value) property of one of
        the radio menus that are part of this radio group.
    */
    @property void value(string newValue)
    {
        this.setVar(_varName, newValue);
    }

    private void add(RadioMenuItem item)
    {
        if (items.empty)
            this.value = item.value;

        items ~= item;
    }

private:
    RadioMenuItem[] items;
    string _varName;
}

///
class RadioMenuItem : Widget
{
    ///
    this(RadioGroupMenu radioGroup, string label, string value)
    {
        enforce(radioGroup !is null, "radioGroup argument must not be null.");
        _radioGroup = radioGroup;
        _label = label;
        _value = value;
        radioGroup.add(this);
        super(CreateFakeWidget.init);
    }

    /** Return the value that's emitted when this radio menu is selected. */
    @property string value()
    {
        return this.getOption!string("value");
    }

    /** Set the value that's emitted when this radio menu is selected. */
    @property void value(string newValue)
    {
        auto oldValue = this.value;

        this.setOption("value", newValue);

        if (_radioGroup.value == oldValue)
            _radioGroup.value = newValue;
    }

    /** Select this radio menu. */
    void select()
    {
        _radioGroup.value = this.value;
    }

private:
    RadioGroupMenu _radioGroup;
    string _label;
    string _value;
}