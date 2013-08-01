/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.button;

import std.conv;
import std.string;

import dtk.callback;
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
    this(Widget master, string text, Callback callback)
    {
        Options o;
        o["text"] = text;
        //~ o["underline"] = "0";
        super(master, "ttk::button", o, callback);
    }

    /** Set the underline option */
    @property void underline(int charIndex)
    {
        string cmd = format("%s configure -underline %s", m_name, charIndex);
        eval(cmd);
    }

    /** Get the underline option */
    @property int underline()
    {
        string cmd = format("%s cget -underline", m_name);
        return to!int(eval(cmd));
    }
}
