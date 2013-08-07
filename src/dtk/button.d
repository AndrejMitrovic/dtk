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
import dtk.options;
import dtk.widget;

enum ButtonStyle
{
    none,  /// generic style

    toolButton,  /// useful for creating widgets for toolbars.
}

class Button : Widget
{
    this(Widget master, string text)
    {
        DtkOptions options;
        options["text"] = text;
        super(master, "ttk::button", options);

        string callbackName = this.createCallback(&onPress);
        this.setOption("command", callbackName);
    }

    /**
        This signal is emitted every time the button is pressed.

        $(RED Note:) When connecting the signal make sure you
        fully specify your parameter names, e.g.:

        button.onPress.connect((Widget w, Event _) { });  // ok
        button.onPress.connect((Widget  , Event  ) { });  // fails at compile-time

        This is a result of Issue 7198: http://d.puremagic.com/issues/show_bug.cgi?id=7198
    */
    public DtkSignal onPress;

    /** Invoke all callbacks associated with this button.. */
    void fireEvent()
    {
        string cmd = format("%s invoke", _name);
        eval(cmd);
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
