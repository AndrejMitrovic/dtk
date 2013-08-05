/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.window;

import dtk.geometry;

import std.range;
import std.stdio;
import std.algorithm;
import std.conv;
import std.string;

alias splitter = std.algorithm.splitter;

import dtk.options;
import dtk.types;
import dtk.utils;
import dtk.widget;

///
class Window : Widget
{
    /** Instantiate a new Window. */
    this(Window parent, int width, int height)
    {
        DtkOptions options;
        options["width"] = to!string(width);
        options["height"] = to!string(height);
        super(parent, "tk::toplevel", options);

        // wait for the window to show up before we issue any commands
        evalFmt("tkwait visibility %s", _name);
    }

    /** Used for the initial implicitly-created Tk root window. */
    package this(Tk_Window window)
    {
        super(".");
        evalFmt("tkwait visibility %s", _name);
    }

    /** Return the current window title. */
    @property string title()
    {
        return evalFmt("wm title %s", _name);
    }

    /** Set a new window title. */
    @property void title(string newTitle)
    {
        evalFmt("wm title %s %s", _name, newTitle._enquote);
    }

    /**
        Get the current window position, relative to its parent.
        The parent is either another window, or the desktop.
    */
    @property Point position()
    {
        string x = evalFmt("winfo x %s", _name);
        string y = evalFmt("winfo y %s", _name);
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
        string width = evalFmt("winfo width %s", _name);
        string height = evalFmt("winfo height %s", _name);
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

    /** Return the size of the screen on which this window is currently displayed on. */
    @property Size screenSize()
    {
        string width = evalFmt("winfo screenwidth %s", _name);
        string height = evalFmt("winfo screenheight %s", _name);
        return Size(to!int(width), to!int(height));
    }

    /** Get the current window geometry. */
    @property Rect geometry()
    {
        return evalFmt("wm geometry %s", _name).toGeometry();
    }

    /**
        Set a new window geometry.
        $(RED bug): See http://stackoverflow.com/questions/18043720/odd-results-for-wm-geometry
    */
    @property void geometry(Rect newGeometry)
    {
        evalFmt("wm geometry %s %s", _name, newGeometry.toEvalString);
        eval("update idletasks");
    }

    /**
        Get the current alpha value for this window.
        A value of 0.0 indicates a fully-transparent window,
        while a value of 1.0 is a fully-opaque window.
    */
    float getAlpha()
    {
        return to!float(evalFmt("wm attributes %s -alpha", _name));
    }

    /**
        Set a specific alpha value for this window within the range [0.0, 1.0].
        A value of 0.0 indicates a fully-transparent window,
        while a value of 1.0 is a fully-opaque window.
    */
    void setAlpha(float alpha = 1.0)
    {
        evalFmt("wm attributes %s -alpha %s", _name, alpha);
    }

    /** Place the window in a mode that takes up the entire screen. */
    void maximizeWindow()
    {
        evalFmt("wm attributes %s -fullscreen 1", _name);
    }

    /** Restore the maximized window back to its original size. */
    void unmaximizeWindow()
    {
        evalFmt("wm attributes %s -fullscreen 0", _name);
    }

    /** Minimize the window. */
    void minimizeWindow()
    {
        evalFmt("wm iconify %s", _name);
    }

    /** Restore the minimized window. */
    void unminimizeWindow()
    {
        evalFmt("wm deiconify %s", _name);
    }

    /** Make this the topmost window which will be displayed above all other windows. */
    void setTopWindow()
    {
        evalFmt("wm attributes %s -topmost 1", _name);
    }

    /**
        Return a range of all child widgets. This is a range rather than a container
        since there is a required lookup of the mapping of a Tcl widget path name
        into a D widget.
    */
    @property auto childWidgets()
    {
        string paths = evalFmt("winfo children %s", _name);
        return map!(a => Widget.lookupWidgetPath(a))(paths.splitter);
    }

    /** Return the parent window of this window, or $(D null) if this window is the main window. */
    @property Window parentWindow()
    {
        string windowPath = evalFmt("winfo parent %s", _name);
        return cast(Window)Widget.lookupWidgetPath(windowPath);
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
