/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.menu;

import dtk.app;
import dtk.dispatch;
import dtk.event;
import dtk.imports;
import dtk.interpreter;
import dtk.signals;
import dtk.types;
import dtk.utils;

import dtk.widgets.widget;
import dtk.widgets.window;

class CommonMenu : Widget
{
    ///
    package this(Widget parent, TkType tkType, WidgetType widgetType)
    {
        super(parent, tkType, widgetType);
        this.setOption("tearoff", 0);  // disable tearoff by default
    }

    /** Create and add a menu to this menu and return it. */
    final Menu addMenu(string menuName)
    {
        auto menu = new Menu(this, menuName);
        tclEvalFmt("%s add cascade -menu %s -label %s", _name, menu._name, menuName._tclEscape);
        return menu;
    }

    /** Create and insert a menu at a specific position and return it. */
    final Menu insertMenu(int index, string menuName)
    {
        auto menu = new Menu(this, menuName);
        tclEvalFmt("%s insert %s cascade -menu %s -label %s", _name, index, menu._name, menuName._tclEscape);
        return menu;
    }

    /** Add an item to this menu and return it. */
    final MenuItem addItem(string label)
    {
        auto menuItem = new MenuItem(label);

        tclEvalFmt("%s add command -label %s -command %s", _name, label._tclEscape,
            getCommand(MenuAction.command, menuItem));

        return menuItem;
    }

    /** Insert an item at a specific position and return it. */
    final MenuItem insertItem(int index, string label)
    {
        auto menuItem = new MenuItem(label);

        tclEvalFmt("%s insert %s command -label %s -command %s", _name, index, label._tclEscape,
            getCommand(MenuAction.command, menuItem));

        return menuItem;
    }

    /** Add a toggle menu item to this menu. */
    final ToggleMenuItem addToggleItem(string label, string offValue = "0", string onValue = "1")
    {
        auto menuItem = new ToggleMenuItem(label, offValue, onValue);

        tclEvalFmt("%s add checkbutton -label %s -variable %s -offvalue %s -onvalue %s -command %s",
            _name, label._tclEscape, menuItem._toggleVarName, offValue._tclEscape, onValue._tclEscape,
            getCommand(MenuAction.command, menuItem));

        return menuItem;
    }

    /** Insert a toggle menu item at a specific position. */
    final ToggleMenuItem insertToggleItem(int index, string label, string offValue = "0", string onValue = "1")
    {
        auto menuItem = new ToggleMenuItem(label, offValue, onValue);

        tclEvalFmt("%s insert %s checkbutton -label %s -variable %s -offvalue %s -onvalue %s -command %s",
            _name, index, label._tclEscape, menuItem._toggleVarName, offValue._tclEscape, onValue._tclEscape,
            getCommand(MenuAction.command, menuItem));

        return menuItem;
    }

    /** Add a radio menu group to this menu. */
    final RadioGroupMenu addRadioGroup(RadioItem[] radioItems...)
    {
        auto radioGroup = new RadioGroupMenu();

        foreach (radioItem; radioItems)
        {
            radioGroup.add(radioItem);

            tclEvalFmt("%s add radiobutton -label %s -variable %s -value %s -command %s",
                _name, radioItem.label._tclEscape, radioGroup._varName, radioItem.value._tclEscape,
                getCommand(MenuAction.radio, radioGroup));
        }

        return radioGroup;
    }

    /** Insert a radio menu group at a specific position. */
    final RadioGroupMenu insertRadioGroup(int index, RadioItem[] radioItems...)
    {
        auto radioGroup = new RadioGroupMenu();

        foreach (radioItem; radioItems)
        {
            radioGroup.add(radioItem);

            tclEvalFmt("%s insert %s radiobutton -label %s -variable %s -value %s -command %s",
                _name, index++, radioItem.label._tclEscape, radioGroup._varName, radioItem.value._tclEscape,
                getCommand(MenuAction.radio, radioGroup));
        }

        return radioGroup;
    }

    private string getCommand(MenuAction menuAction, Widget widget)
    {
        auto menuBar = this.getRootMenuBar();

        return format(`"%s %s %s %s %s"`,
                      _dtkCallbackIdent,
                      EventType.menu,
                      menuAction,
                      menuBar._name,
                      widget._name);
    }
}

class MenuBar : CommonMenu
{
    /** Signal emitted when a menu item is selected. */
    public Signal!MenuEvent onMenuEvent;

    ///
    package this(Widget parent)
    {
        super(parent, TkType.menu, WidgetType.menubar);
    }
}

///
class Menu : CommonMenu
{
    package this(Widget parent, string label)
    {
        _label = label;
        super(parent, TkType.menu, WidgetType.menu);
    }

    /** Add a dividing line. */
    final void addSeparator()
    {
        tclEvalFmt("%s add separator", _name);
    }

    /** Insert a dividing line at a specific position. */
    final void insertSeparator(int index)
    {
        tclEvalFmt("%s insert %s separator", _name, index);
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
    package this(string label)
    {
        _label = label;
        super(CreateFakeWidget.init, WidgetType.menuitem);
    }

    /** Get the menu item label. */
    @property string label() const
    {
        return _label;
    }

    override string toString() const
    {
        return format("%s(%s)", __traits(identifier, typeof(this)), _label);
    }

private:
    string _label;
}

///
class ToggleMenuItem : Widget
{
    ///
    package this(string label, string offValue = "0", string onValue = "1")
    {
        _label = label;
        _offValue = offValue;
        _onValue = onValue;
        _toggleVarName = this.makeVar();
        super(CreateFakeWidget.init, WidgetType.checkmenu_item);
    }

    /** Get the menu item label. */
    @property string label() const
    {
        return _label;
    }

    /** Get the current state of the checkbutton. It should equal to either onValue or offValue. */
    @property string value() const
    {
        return tclGetVar!string(_toggleVarName);
    }

    /** Get the on value. */
    @property string onValue() const
    {
        return _onValue;
    }

    /** Get the off value. */
    @property string offValue() const
    {
        return _offValue;
    }

    /** Toggle the toggle menu on. */
    void toggleOn()
    {
        tclSetVar(_toggleVarName, onValue());
        this.invokeCallback();
    }

    /** Toggle the toggle menu off. */
    void toggleOff()
    {
        tclSetVar(_toggleVarName, offValue());
        this.invokeCallback();
    }

    private void invokeCallback()
    {
        auto menuBar = this.getRootMenuBar();
        tclEvalFmt("%s %s %s %s %s",
            _dtkCallbackIdent, EventType.menu, MenuAction.toggle, menuBar._name, _name);
    }

    override string toString() const
    {
        bool isOn = value == onValue;

        return format("%s(%s - %s : %s)",
            __traits(identifier, typeof(this)), _label, isOn ? "on" : "off", isOn ? _onValue : _offValue);
    }

private:
    string _label;
    string _toggleVarName;
    string _offValue;
    string _onValue;
}

///
class RadioGroupMenu : Widget
{
    // todo: this is not really a Widget, but it needs to have a callback mechanism
    this()
    {
        super(CreateFakeWidget.init, WidgetType.radiogroup_menu);
        _varName = makeVar();
    }

    /**
        Get the currently selected radio menu value.
        It should equal to the $(D value) property of one of
        the radio menus that are part of this radio group.
    */
    @property string value() const
    {
        return tclGetVar!string(_varName);
    }

    /**
        Set the currently selected radio menu value.
        It should equal to the $(D value) property of one of
        the radio items that are part of this radio group.
    */
    @property void value(string newValue)
    {
        tclSetVar(_varName, newValue);
    }

    private void add(RadioItem item)
    {
        _items ~= item;
    }

    ///
    @property const(RadioItem[]) radioItems() const
    {
        return _items;
    }

    override string toString() const
    {
        return format("%s(%s)", __traits(identifier, typeof(this)), value);
    }

private:
    RadioItem[] _items;
    string _varName;
}

///
struct RadioItem
{
    this(string label)
    {
        this.label = label;
        this.value = label;
    }

    this(string label, string value)
    {
        this.label = label;
        this.value = value;
    }

    ///
    const(string) label;

    ///
    const(string) value;
}

private MenuBar getRootMenuBar(Widget widget)
{
    Widget parent = widget;

    do
    {
        if (parent.widgetType == WidgetType.menubar)
            return StaticCast!MenuBar(parent);
        else
            parent = parent.parentWidget;
    } while (parent !is null);

    assert(0);
}
