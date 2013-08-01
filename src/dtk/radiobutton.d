/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.radiobutton;

import dtk.widget;
import dtk.options;

import std.conv;

class Radiobutton : Widget
{
    this(Widget master, string text, int value)
    {
        DtkOptions o;
        o["text"]  = text;
        o["value"] = to!string(value);
        super(master, "radiobutton", o);
    }

    void flash()
    {
        eval("flash");
    }

    void deselect()
    {
        eval("deselect");
    }

    void select()
    {
        eval("select");
    }
}
