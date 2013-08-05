/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.window;

import std.range;
import std.stdio;
import std.algorithm;
import std.conv;
import std.string;

alias splitter = std.algorithm.splitter;

import dtk.options;
import dtk.types;
import dtk.widget;

struct Point
{
    int x;
    int y;
}

struct Size
{
    int width;
    int height;
}

struct Geometry
{
    int xOffset;
    int yOffset;
    int width;
    int height;
}

class Window : Widget
{
    /** Instantiate a new Window. */
    this(int width, int height)
    {
        DtkOptions options;
        options["width"] = to!string(width);
        options["height"] = to!string(height);
        super(NullParent, "tk::toplevel", options);

        // wait for the window to show up before we issue any commands
        eval(format("tkwait visibility %s", _name));
    }

    /** Used for the initial implicitly-created Tk root window. */
    package this(Tk_Window window)
    {
        super(".");
        eval(format("tkwait visibility %s", _name));
    }

    /**
        Get the current window position, relative to its parent.
        The parent is either another window, or the desktop.
    */
    @property Point position()
    {
        string x = eval(format("winfo x %s", _name));
        string y = eval(format("winfo y %s", _name));
        return Point(to!int(x), to!int(y));
    }

    /** Get the last requested size for this window. */
    @property Size requestedSize()
    {
        string width = eval(format("winfo reqwidth %s", _name));
        string height = eval(format("winfo reqheight %s", _name));
        return Size(to!int(width), to!int(height));
    }

    /** Get the current window geometry. */
    @property Geometry geometry()
    {
        string cmd = format("wm geometry %s", _name);
        string result = eval(cmd);
        return result.toGeometry();
    }

    /**
        Set a new window geometry.
        $(RED bug): See http://stackoverflow.com/questions/18043720/odd-results-for-wm-geometry
    */
    @property void geometry(Geometry newGeometry)
    {
        eval(format("wm geometry %s %s", _name, newGeometry.toEvalString));
        eval("update idletasks");
    }

    /**
        Return a range of all child widgets. This is a range rather than a container
        since there is a required lookup of the mapping of a Tcl widget path name
        into a D widget.
    */
    @property auto childWidgets()
    {
        string paths = eval(format("winfo children %s", _name));
        return map!(a => Widget.lookupWidgetPath(a))(paths.splitter);
    }
}

/** Phobos parse functions can't use a custom delimiter. */
private Geometry toGeometry(string input)
{
    typeof(return) result;

    string width = input[0 .. input.countUntil("x")];
    input.findSkip("x");

    auto idx = input.countUntil!(a => a == '+' || a == '-');
    string height = input[0 .. idx];
    input.popFrontN(idx);

    auto idx2 = input.countUntil!(a => a == '+' || a == '-');
    auto idx3 = idx2 + 1 + input[idx2 + 1 .. $].countUntil!(a => a == '+' || a == '-');

    string xOffset = input[0 .. idx3];
    string yOffset = input[idx3 .. $];

    result.width = to!int(width);
    result.height = to!int(height);
    result.xOffset = to!int(xOffset);
    result.yOffset = to!int(yOffset);

    return result;
}

///
unittest
{
    assert("200x200+88-88".toGeometry == Geometry(88, -88, 200, 200));
    assert("200x200-88+88".toGeometry == Geometry(-88, 88, 200, 200));
    assert("200x200+88+88".toGeometry == Geometry(88, 88, 200, 200));
}

private string toEvalString(Geometry geometry)
{
    string width = to!string(geometry.width);
    string height = to!string(geometry.height);

    string xOffset = format("%s%s", geometry.xOffset < 0 ? "" : "+", geometry.xOffset);
    string yOffset = format("%s%s", geometry.yOffset < 0 ? "" : "+", geometry.yOffset);

    return format("%sx%s%s%s", width, height, xOffset, yOffset);
}

///
unittest
{
    assert("200x200+88-88" == Geometry(88, -88, 200, 200).toEvalString);
    assert("200x200-88+88" == Geometry(-88, 88, 200, 200).toEvalString);
    assert("200x200+88+88" == Geometry(88, 88, 200, 200).toEvalString);
}
