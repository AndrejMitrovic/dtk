/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.button;

import std.conv;
import std.string;

import dtk.event;
import dtk.signals;
import dtk.utils;
import dtk.options;
import dtk.widget;

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
        DtkOptions options;
        options["text"] = text;
        super(master, TkType.button, options);

        // invoke calls 'command'
        this.evalFmt("bind %s <Return> { %s invoke }", _name, _name);

        // 'command' calls onEvent
        this.setOption("command", format("%s %s", _eventCallbackIdent, EventType.TkButtonPush));
    }

    /**
        Physically push the button and emit the TkButtonPush event.
        The button is automatically released after ~200 milliseconds.
    */
    void push()
    {
        // push the button
        this.evalFmt("%s state pressed", _name);

        // queue unpush for later
        this.evalFmt("after 200 { %s state !pressed }", _name);

        // meanwhile emit the TkButtonPush event
        this.evalFmt("%s invoke", _name);
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
