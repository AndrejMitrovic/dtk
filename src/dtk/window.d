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

struct Rect
{
    int x;
    int y;
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

    /**
        Set a new window position, relative to its parent.
        The parent is either another window, or the desktop.
    */
    @property void position(Point newPoint)
    {
        auto rect = this.geometry;
        rect.x = newPoint.x;
        rect.y = newPoint.y;
        this.geometry = rect;
    }

    /** Get the current window size. */
    @property Size size()
    {
        string width = eval(format("winfo width %s", _name));
        string height = eval(format("winfo height %s", _name));
        return Size(to!int(width), to!int(height));
    }

    /**
        Set a new window size.
    */
    @property void size(Size newSize)
    {
        auto rect = this.geometry;
        rect.width = newSize.width;
        rect.height = newSize.height;
        this.geometry = rect;
    }

    /** Get the current window geometry. */
    @property Rect geometry()
    {
        string cmd = format("wm geometry %s", _name);
        string result = eval(cmd);
        return result.toGeometry();
    }

    /**
        Set a new window geometry.
        $(RED bug): See http://stackoverflow.com/questions/18043720/odd-results-for-wm-geometry
    */
    @property void geometry(Rect newGeometry)
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
private Rect toGeometry(string input)
{
    typeof(return) result;

    sizediff_t xOffset = input.countUntil("x");
    sizediff_t firstPlus = input.countUntil("+");
    sizediff_t secondPlus = input.countUntil("+") + 1 + input[input.countUntil("+") + 1 .. $].countUntil("+");

    string width = input[0 .. xOffset];
    string height = input[xOffset + 1 .. firstPlus];

    string x = input[firstPlus + 1 .. secondPlus];
    string y = input[secondPlus + 1 .. $];

    result.x = to!int(x);
    result.y = to!int(y);
    result.width = to!int(width);
    result.height = to!int(height);

    return result;
}

///
unittest
{
    assert("200x200+88+-88".toGeometry == Rect(88, -88, 200, 200));
    assert("200x200+-88+88".toGeometry == Rect(-88, 88, 200, 200));
    assert("200x200+88+88".toGeometry == Rect(88, 88, 200, 200));
}

private string toEvalString(Rect geometry)
{
    string width = to!string(geometry.width);
    string height = to!string(geometry.height);

    string xOffset = format("+%s", geometry.x);
    string yOffset = format("+%s", geometry.y);

    return format("%sx%s%s%s", width, height, xOffset, yOffset);
}

///
unittest
{
    assert(Rect(88, -88, 200, 200).toEvalString == "200x200+88+-88");
    assert(Rect(-88, 88, 200, 200).toEvalString == "200x200+-88+88");
    assert(Rect(88, 88, 200, 200).toEvalString  == "200x200+88+88");
}
