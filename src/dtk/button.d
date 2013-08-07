/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.button;

import std.conv;
import std.string;

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
*/
enum DefaultMode
{
    normal,   /// this button may become the default button
    active,   /// this button is currently the default button
    disabled, /// this button cannot become the default button
}

class Button : Widget
{
    this(Widget master, string text)
    {
        DtkOptions options;
        options["text"] = text;
        super(master, "ttk::button", options);

        this.setOption("command", this.createCallback(&onPress));
        this.evalFmt("bind %s <Return> { %s invoke }", _name, _name);

        this.evalFmt("bind %s <Enter> { %s %s }", _name, this.createCallback(&onMouseEnter), eventArgs);
        this.evalFmt("bind %s <Leave> { %s %s }", _name, this.createCallback(&onMouseLeave), eventArgs);
    }

    /** Signals: */

    /**
        This signal is emitted when this button is pressed.
        The button may either be pressed via the mouse, or
        the Enter key if the button is currently selected.

        $(B Note:) The Event parameter will not hold any interesting state.

        Example:

        ----
        auto button = new Button(...);
        button.onPress.connect((Widget w, Event e) {  }
        ----
    */
    public DtkSignal onPress;

    /**
        This signal is emitted when the mouse cursor enters the button area.

        $(B Note:) The Event parameter will not hold any interesting state.

        Example:

        ----
        auto button = new Button(...);
        button.onMouseEnter.connect((Widget w, Event e) {  }
        ----
    */
    public DtkSignal onMouseEnter;

    /**
        This signal is emitted when the mouse cursor leaves the button area.

        $(B Note:) The Event parameter will not hold any interesting state.

        $(RED Behavior note:) If the mouse cursor leaves the button area
        too quickly, and at the same time leaves the window area, the
        signal may be emitted with a delay of several ~100 milliseconds.
        To make sure the signal is emmitted as soon as the cursor leaves
        the button area, ensure that the button does not lay directly on
        an edge of a window (e.g. add some padding space to the button).

        Example:

        ----
        auto button = new Button(...);
        button.onMouseLeave.connect((Widget w, Event e) {  }
        ----
    */
    public DtkSignal onMouseLeave;

    /** Invoke all callbacks associated with this button. */
    void fireEvent()
    {
        evalFmt("%s invoke", _name);
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
