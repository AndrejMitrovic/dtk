/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.scale;

import std.conv;
import std.string;

import dtk.widget;
import dtk.options;

class Scale : Widget
{
    this(Widget master, string text)
    {
        Options o;
        o["label"] = text;
        super(master, "scale", o);
    }

    int get()
    {
        return to!int(eval("get"));
    }

    void set(int value)
    {
        eval("set " ~ to!string(value));
    }
}
