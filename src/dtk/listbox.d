/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.listbox;

import dtk.widget;
import dtk.options;

import std.conv;

class Listbox : Widget
{
    this(Widget master)
    {
        Options o;
        super(master, "listbox", o);
    }

    void insert(int index, string[] elements)
    {
        string result;

        foreach (cur; elements)
            result ~= " " ~ cur;

        eval("insert " ~ to!string(index) ~ result);
    }

    // note: never name a variable 'to', it will conflict with std.conv.to
    void del(int from, int towards)
    {
        eval("delete " ~ to!string(from) ~ " " ~ to!string(towards));
    }

    int size()
    {
        return to!int(eval("size"));
    }

    string get(int index)
    {
        return eval("get " ~ to!string(index) ~ " " ~ to!string(index));
    }

    int curselection()
    {
        return to!int(eval("curselection"));
    }
}
