/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.canvas;

import std.stdio;
import std.conv;
import std.string;

import dtk.widget;
import dtk.options;
import dtk.utils;

const string default_fill_color = "black";

class Tag : Widget
{
    this(Canvas parent, string tag)
    {
        super();
        m_interp = parent.interp;
        m_name   = tag;
        m_canvas = parent;
    }
protected:
    Canvas m_canvas;
}

class Canvas : Widget
{
    this(Widget master, int width = 100, int height = 100)
    {
        Options o;
        o["width"]  = to!string(width);
        o["height"] = to!string(height);
        super(master, "canvas", o);
    }

    void clear()
    {
        eval("delete all");
    }

    string line(int[] coords ...)
    {
        return line(default_fill_color, coords);
    }

    string line(string fill, int[] coords ...)
    {
        return eval("create line " ~ spaceJoin(coords) ~ " -fill " ~ fill);
    }

    string oval(string fill, int x0, int y0, int x1, int y1, string args = "")
    {
        return eval("create oval " ~ spaceJoin([x0, y0, x1, y1]) ~ " -fill " ~ fill ~ " " ~ args);
    }

    string oval(int x0, int y0, int x1, int y1, string args = "")
    {
        return oval(default_fill_color, x0, y0, x1, y1, args);
    }

    string text(string color, string txt, int x, int y)
    {
        return eval("create text " ~ spaceJoin([x, y]) ~ " -text \"" ~ txt ~ "\" -fill " ~ color);
    }

    string text(string txt, int x, int y)
    {
        return text(default_fill_color, txt, x, y);
    }

    string rectangle(string color, int[] coords)
    {
        return eval("create rectangle " ~ spaceJoin(coords) ~ "   -fill " ~ color);
    }

    string rectangle(int[] coords)
    {
        return rectangle(default_fill_color, coords);
    }

    Tag addtag(string tag, string command, string args)
    {
        eval(" addtag " ~ tag ~ " " ~ command ~ " " ~ args);
        return new Tag(this, tag);
    }

    string cdelete(string tag)
    {
        return eval(" delete " ~ tag);
    }

    string cdelete(Tag tag)
    {
        return cdelete(tag.name());
    }
}
