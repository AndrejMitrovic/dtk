/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.entry;

import std.string;
import std.conv;

import dtk.widget;
import dtk.options;

class Entry : Widget
{
    this(Widget master, string text = "")
    {
        DtkOptions o;
        o["text"] = text;
        super(master, "ttk::entry", o);
    }

    //~ string text()
    //~ {
        //~ return eval("get");
    //~ }

    override void clean()
    {
        int len = text().length;
        eval("delete 0 " ~ to!string(len));
    }

    //~ void text(string txt)
    //~ {
        //~ clean();
        //~ eval(" insert 0 \"" ~ txt ~ "\"");
    //~ }
}
