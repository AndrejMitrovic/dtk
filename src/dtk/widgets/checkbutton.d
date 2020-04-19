/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.checkbutton;

import dtk.app;
import dtk.dispatch;
import dtk.event;
import dtk.image;
import dtk.interpreter;
import dtk.signals;
import dtk.utils;
import dtk.types;
import dtk.widgets.button;
import dtk.widgets.widget;

import std.conv;
import std.format;
import std.range;

///
class CheckButton : Widget
{
    ///
    this(Widget parent, string text = null)
    {
        super(parent, TkType.checkbutton, WidgetType.checkbutton);

        if (!text.empty)
            this.setOption("text", text);

        _toggleVarName = makeVar();
        this.setOption("variable", _toggleVarName);

        this.toggleOff();

        tclEvalFmt("%s configure -command %s", _name,
            format(`"%s %s %s"`,
                _dtkCallbackIdent,
                EventType.check_button,
                _name));

        // keyboard binding
        tclEvalFmt("bind %s <Return> { %s invoke }", _name, _name);
    }

    /**
        Signal emitted when the check button is toggled.
    */
    public Signal!CheckButtonEvent onCheckButtonEvent;

    /**
        Toggle the chekbutton to On. This will set its value to the
        value retrieived from onValue, and will emit a ButtonEvent.
    */
    void toggleOn()
    {
        tclEvalFmt("set %s %s", _toggleVarName, onValue()._tclEscape);
        this.callDtkCallback();
    }

    /**
        Toggle the chekbutton to Off. This will set its value to the
        value retrieived from offValue, and will emit a ButtonEvent.
    */
    void toggleOff()
    {
        tclEvalFmt("set %s %s", _toggleVarName, offValue()._tclEscape);
        this.callDtkCallback();
    }

    // todo: not yet implemented
    /+ /**
        Check whether the checkbutton is in an alternate indeterminate state.
    */
    bool isUnset()
    {
        return checkState("alternate");
    }

    /**
        Set the checkbutton in an alternate indeterminate state.
    */
    void unset()
    {
        _unsetVar();
    } +/

    /**
        Toggle the checkbutton.
    */
    void toggle()
    {
        tclEvalFmt("%s invoke", _name);  // callback is called automatically
    }

    /** Get the current state of the checkbutton. It should equal to either onValue or offValue. */
    @property string value()
    {
        return tclGetVar!string(_toggleVarName);
    }

    /** Return the value that's emitted when the check button is toggled on. */
    @property string onValue()
    {
        return this.getOption!string("onvalue");
    }

    /** Set the value that's emitted when the check button is toggled on. */
    @property void onValue(string newOnValue)
    {
        this.setOption("onvalue", newOnValue);
    }

    /** Return the value that's emitted when the check button is toggled off. */
    @property string offValue()
    {
        return this.getOption!string("offvalue");
    }

    /** Set the value that's emitted when the check button is toggled off. */
    @property void offValue(string newOffValue)
    {
        this.setOption("offvalue", newOffValue);
    }

    /**
        Get the image associated with this check button,
        or null if no image was set.
    */
    @property Image image()
    {
        string imagePath = this.getOption!string("image");
        return cast(Image)Widget.lookupWidgetPath(imagePath);
    }

    /**
        Set an image for this check button. If image is null,
        the button is reset to display text only.
    */
    @property void image(Image newImage)
    {
        this.setOption("image", newImage ? newImage._name : "");
    }

    /** Get the 0-based index of the underlined character, or -1 if no character is underlined. */
    @property int underline()
    {
        return this.getOption!int("underline");
    }

    /** Set the underlined character using a 0-based index. */
    @property void underline(int charIndex)
    {
        this.setOption("underline", charIndex);
    }

    /** Get the text string displayed in the widget. */
    @property string text()
    {
        return this.getOption!string("text");
    }

    /** Set the text string displayed in the widget. */
    @property void text(string newText)
    {
        this.setOption("text", newText);
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

    /* The callback has to be called manually since 'invoke' toggles the checkbutton. */
    private void callDtkCallback()
    {
        tclEvalFmt("%s %s %s", _dtkCallbackIdent, EventType.check_button, _name);
    }

private:
    string _toggleVarName;
}
