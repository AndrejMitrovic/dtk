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

struct ButtonOptions
{
    /**
        If set, specifies the integer index (0-based) of a
        character to underline in the text string.
        The underlined character is used for mnemonic activation.
    */
    int underline = -1;
}

class Button : Widget
{
    this(Widget master, string text)
    {
        Options options;
        options["text"] = text;
        super(master, "ttk::button", options);
    }

    /** Set the callback to evaluate when this button is invoked. */
    @property void onEvent(DtkCallback callback)
    {
        string callbackName = this.createCallback(callback);
        this.setOption("command", callbackName);
    }
}
