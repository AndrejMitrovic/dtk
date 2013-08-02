/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.button;

import std.conv;
import std.string;

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
    }

    /** Set the callback to invoke when this button is triggered. */
    @property void onEvent(DtkCallback callback)
    {
        string callbackName = this.createCallback(callback);
        this.setOption("command", callbackName);
    }

    /** Invoke the callback if one was set with a call to $(D onEvent). */
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

    /** Set the button style. */
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
