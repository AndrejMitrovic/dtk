/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.radiobutton;

import std.exception;
import std.range;
import std.string;

import dtk.app;
import dtk.event;
import dtk.image;
import dtk.interpreter;
import dtk.signals;
import dtk.types;
import dtk.utils;

import dtk.widgets.button;
import dtk.widgets.widget;

///
class RadioGroup : Widget
{
    // todo: this is not really a Widget, but it needs to have a callback mechanism
    this()
    {
        super(CreateFakeWidget.init, WidgetType.radiogroup);
        _varName = makeTracedVar(TkEventType.TkRadioButtonSelect);
    }

    /**
        Get the currently selected radio button value.
        It should equal to the $(D value) property of one of
        the radio buttons that are part of this radio group.
    */
    @property string value()
    {
        return tclGetVar!string(_varName);
    }

    /**
        Set the currently selected radio button value.
        It should equal to the $(D value) property of one of
        the radio buttons that are part of this radio group.
    */
    @property void value(string newValue)
    {
        tclSetVar(_varName, newValue);
    }

    private void add(RadioButton button)
    {
        if (_isEmpty)
        {
            _isEmpty = false;
            this.value = button.value;
        }
    }

private:
    string _varName;
    bool _isEmpty = true;
}

///
class RadioButton : Widget
{
    ///
    this(Widget master, RadioGroup radioGroup, string text, string value)
    {
        enforce(radioGroup !is null, "radioGroup argument must not be null.");

        super(master, TkType.radiobutton, WidgetType.radiobutton);

        this.setOption("text", text);
        this.setOption("variable", radioGroup._varName);
        this.setOption("value", value);

        // keyboard binding
        tclEvalFmt("bind %s <Return> { %s invoke }", _name, _name);

        radioGroup.add(this);
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

        if (_radioGroup.value == oldValue)
            _radioGroup.value = newValue;
    }

    /** Select this radio button. */
    void select()
    {
        _radioGroup.value = this.value;
    }

    /** Get the current button style. */
    @property ButtonStyle style()
    {
        return this.getOption!string("style").toButtonStyle;
    }

    /** Set a new button style. */
    @property void style(ButtonStyle newStyle)
    {
        this.setOption("style", newStyle.toString);
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
