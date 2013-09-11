/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.button;

import std.range;
import std.string;

import dtk.dispatch;
import dtk.event;
import dtk.geometry;
import dtk.image;
import dtk.interpreter;
import dtk.signals;
import dtk.types;
import dtk.utils;

import dtk.widgets.widget;

/// Various button styles
enum ButtonStyle
{
    none,  /// generic style

    toolButton,  /// useful for creating widgets for toolbars.
}

/**
    The default mode setting for a button.
    In a dialog box one button may be designated the default button,
    which means it is the one that by default gets invoked when the
    user presses Enter.

    The initial default mode setting for a button is set to normal.

    $(RED Note:) Currently this option is not usable anywhere yet,
    see: http://stackoverflow.com/q/18093608/279684

    However you may use $(D widget.focus()) to set the active keyboard
    focus to a widget.
*/
enum DefaultMode
{
    normal,   /// this button may become the default button
    active,   /// this button is currently the default button
    disabled, /// this button cannot become the default button
}

///
class Button : Widget
{
    ///
    this(Widget master, string text)
    {
        super(master, TkType.button, WidgetType.button);

        // return key issues invoke, which calls 'command'
        tclEvalFmt("bind %s <Return> { %s invoke }", _name, _name);

        tclEvalFmt("%s configure -command %s", _name,
            format(`"%s %s %s %s"`,
                _dtkCallbackIdent,
                EventType.button,
                ButtonAction.push,
                _name));

        // 'command' sends an event
        //~ this.setOption("command",

        this.setOption("text", text);
    }

    /**
        Signal emitted when the button is pushed.
    */
    public Signal!ButtonEvent onButtonEvent;

    /**
        Physically push the button and emit a ButtonEvent.
        The button is automatically released after ~100 milliseconds.
        Note that this doesn't focus on the widget.
    */
    void push()
    {
        tclEvalFmt("ttk::button::activate %s", _name);

        // todo: could also use:
        //~ proc activateButton {w} {
            //~ event generate $w <Button-1> -warp yes
            //~ event generate $w <ButtonRelease-1>
        //~ }
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

    /** Get the default mode for this button. */
    @property DefaultMode defaultMode()
    {
        return this.getOption!DefaultMode("default");
    }

    /** Set the default mode for this button. */
    @property void defaultMode(DefaultMode defaultMode)
    {
        this.setOption("default", to!string(defaultMode));
    }

    /**
        Get the image associated with this button,
        or null if no image was set.
    */
    @property Image image()
    {
        string imagePath = this.getOption!string("image");
        return cast(Image)Widget.lookupWidgetPath(imagePath);
    }

    /**
        Set an image for this button. If image is null,
        the button is reset to display text only.
    */
    @property void image(Image newImage)
    {
        this.setOption("image", newImage ? newImage._name : "{}");
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
}

package ButtonStyle toButtonStyle(string style)
{
    switch (style) with (ButtonStyle)
    {
        case "":           return none;
        case "Toolbutton": return toolButton;
        default: assert(0, format("Unhandled style: '%s'", style));
    }
}

package string toString(ButtonStyle style)
{
    final switch (style) with (ButtonStyle)
    {
        case none:       return "";
        case toolButton: return "Toolbutton";
    }
}
