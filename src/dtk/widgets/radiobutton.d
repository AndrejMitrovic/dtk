/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.radiobutton;

import dtk.app;
import dtk.dispatch;
import dtk.event;
import dtk.image;
import dtk.interpreter;
import dtk.signals;
import dtk.types;
import dtk.utils;
import dtk.widgets.button;
import dtk.widgets.widget;

import std.algorithm;
import std.container.slist;
import std.conv;
import std.exception;
import std.format;
import std.range;

///
class RadioGroup : Widget
{
    this(Widget parent)
    {
        // we use a frame Tk type to allow Tk calls to work,
        // but we don't subclass from Frame to disallow user
        // configuration.
        super(parent, TkType.frame, WidgetType.radiogroup);

        _varName = makeVar();
        tclEvalFmt(`trace add variable %s write { %s %s %s }`, _varName, _dtkCallbackIdent, EventType.radio_button, _name);
    }

    /**
        Signal emitted when a radio button in the radio group is selected.
    */
    public Signal!RadioButtonEvent onRadioButtonEvent;

    /** Add a new radio button to this radio group. */
    RadioButton addButton(string text, string value)
    {
        auto button = new RadioButton(this, text, value);

        if (_buttons.empty)
            _selectButton(button);

        enforce(find(_buttons[], button).empty,
            format("Radion button '%s' is already part of this radio group", button));

        _buttons.stableInsertAfter(_buttons[], button);

        return button;
    }

    /** Get the currently selected radio button. */
    @property RadioButton selectedButton()
    {
        return _findButton(selectedValue);
    }

    /**
        Set the selected radio button.
        The radio button must be part of this radio group.
    */
    @property void selectedButton(RadioButton button)
    {
        enforce(!find(_buttons[], button).empty,
            format("Radion button '%s' is not part of this radio group", button));

        _selectButton(button);
    }

    /**
        Get the string value of the currently selected radio button.
        It should equal to the $(D value) property of one of
        the radio buttons that are part of this radio group.
    */
    @property string selectedValue()
    {
        return tclGetVar!string(_varName);
    }

    /**
        Set the currently selected radio button by using the
        matching string value. The value should equal to
        one of the radio buttons' values that are part of
        this radio group.
    */
    @property void selectedValue(string newValue)
    {
        auto button = enforce(_findButton(newValue),
            format("Radion button with value '%s' was not found in this radio group", newValue));

        _selectButton(button);
    }

    private void _selectButton(RadioButton button)
    {
        tclSetVar(_varName, button.value);
    }

    // find the button with this value
    private RadioButton _findButton(string value)
    {
        auto range = find!((a, b) => a.value == b)(_buttons[], value);
        return range.empty ? null : range.front;
    }

    // when a currently selected radio button has its value changed,
    // this function needs to be called to reflect this.
    private void _updateSelectedValue(string newValue)
    {
        tclSetVar(_varName, newValue);
    }

private:
    string _varName;
    SList!RadioButton _buttons;
}

///
class RadioButton : Widget
{
    ///
    private this(RadioGroup radioGroup, string text, string value)
    {
        enforce(radioGroup !is null, "radioGroup argument must not be null.");

        super(radioGroup, TkType.radiobutton, WidgetType.radiobutton);

        this.setOption("text", text);
        this.setOption("variable", radioGroup._varName);
        this.setOption("value", value);

        // keyboard binding
        tclEvalFmt("bind %s <Return> { %s invoke }", _name, _name);
        _radioGroup = radioGroup;
    }

    /** Return the value that's emitted when this radio button is selected. */
    @property string value()
    {
        return this.getOption!string("value");
    }

    /** Set the value that's emitted when this radio button is selected. */
    @property void value(string newValue)
    {
        auto oldValue = this.value;

        this.setOption("value", newValue);

        // if the radio group had this button selected,
        // it needs a forced update to the new value of this button
        if (_radioGroup.selectedValue == oldValue)
            _radioGroup._updateSelectedValue(newValue);
    }

    /** Select this radio button. */
    void select()
    {
        _radioGroup.selectedButton = this;
    }

    /**
        Get the image associated with this radio button,
        or null if no image was set.
    */
    @property Image image()
    {
        string imagePath = this.getOption!string("image");
        return cast(Image)Widget.lookupWidgetPath(imagePath);
    }

    /**
        Set an image for this radio button. If image is null,
        the radio button is reset to display text only.
    */
    @property void image(Image newImage)
    {
        this.setOption("image", newImage ? newImage._name : "");
    }

    /**
        Get the text width currently set.
        If no specific text width is set, 0 is returned,
        which implies a natural text width is used.
    */
    @property int textWidth()
    {
        string input = this.getOption!string("width");
        if (input.empty)
            return 0;

        return to!int(input);
    }

    /**
        Set the text space width. If greater than zero, specifies how much space
        in character widths to allocate for the text label. If less than zero,
        specifies a minimum width. If zero, the natural width of the text label is used.
    */
    @property void textWidth(int newWidth)
    {
        this.setOption("width", newWidth);
    }

private:
    RadioGroup _radioGroup;
}
