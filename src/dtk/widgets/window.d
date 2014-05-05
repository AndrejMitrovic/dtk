/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.window;

import dtk.event;
import dtk.geometry;
import dtk.imports;
import dtk.interpreter;
import dtk.types;
import dtk.utils;

import dtk.widgets.menu;
import dtk.widgets.sizegrip;
import dtk.widgets.widget;

///
enum CanResizeWidth
{
    no,
    yes,
}

///
enum CanResizeHeight
{
    no,
    yes,
}

///
class Window : Widget
{
    /** Instantiate a new Window. */
    this(Window parent, int width, int height)
    {
        super(parent, TkType.toplevel, WidgetType.window);

        this.setOption("width", width);
        this.setOption("height", height);

        // wait for the window to show up before we issue any commands
        tclEvalFmt("tkwait visibility %s", _name);
    }

    /** Used for the initial implicitly-created Tk root window. */
    this(Tk_Window window)
    {
        super(CreateToplevel.init, WidgetType.window);

        version(unittest)
        version(DTK_UNITTEST)
        {
            tclEvalFmt("tkwait visibility %s", _name);
        }
    }

    /** Return the current window title. */
    @property string title()
    {
        return tclEvalFmt("wm title %s", _name);
    }

    /** Set a new window title. */
    @property void title(string newTitle)
    {
        tclEvalFmt("wm title %s %s", _name, newTitle._tclEscape);
    }

    alias position = super.position;

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

    alias size = super.size;

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

    alias geometry = super.geometry;

    /**
        Set a new window geometry.
        $(RED bug): See http://stackoverflow.com/questions/18043720/odd-results-for-wm-geometry
    */
    @property void geometry(Rect newGeometry)
    {
        tclEvalFmt("wm geometry %s %s", _name, newGeometry.toEvalString);
        tclEval("update idletasks");
    }

    /**
        Set whether the window can be resized horizontally and/or vertically by the user.

        $(B Note:) This still allows resizing of the window by using the $(D size) property,
        it only disallows the user to resize the window externally (e.g. with a mouse).

        $(B Note:) As a visual aid to the user you should call $(D disableSizegrip())
        if you've enabled a size grip but disabled the window to be resized in
        all directions.
    */
    void setResizable(CanResizeWidth canResizeWidth, CanResizeHeight canResizeHeight)
    {
        tclEvalFmt("wm resizable %s %s %s", _name, canResizeWidth, canResizeHeight);
    }

    /** Set a sizegrip for the window. */
    void enableSizegrip()
    {
        _sizegrip = new Sizegrip(this);
    }

    /** Remove any sizegrip in the window. */
    void disableSizegrip()
    {
        if (_sizegrip !is null)
        {
            _sizegrip.destroy();
            _sizegrip = null;
        }
    }

    /** Return the size of the screen on which this window is currently displayed on. */
    @property Size screenSize()
    {
        string width = tclEvalFmt("winfo screenwidth %s", _name);
        string height = tclEvalFmt("winfo screenheight %s", _name);
        return Size(to!int(width), to!int(height));
    }

    /** Get the current width of the border. */
    @property int borderWidth()
    {
        return this.getOption!int("borderwidth");
    }

    /** Set the desired width of the border. */
    @property void borderWidth(int newBorderWidth)
    {
        this.setOption("borderwidth", newBorderWidth);
    }

    /** Get the current border style. */
    @property BorderStyle borderStyle()
    {
        return this.getOption!BorderStyle("relief");
    }

    /** Set the border style. */
    @property void borderStyle(BorderStyle newBorderStyle)
    {
        this.setOption("relief", newBorderStyle.text);
    }

    /**
        Get the current alpha value for this window.
        A value of 0.0 indicates a fully-transparent window,
        while a value of 1.0 is a fully-opaque window.
    */
    float getAlpha()
    {
        return to!float(tclEvalFmt("wm attributes %s -alpha", _name));
    }

    /**
        Set a specific alpha value for this window within the range [0.0, 1.0].
        A value of 0.0 indicates a fully-transparent window,
        while a value of 1.0 is a fully-opaque window.
    */
    void setAlpha(float alpha = 1.0)
    {
        alpha.checkFinite();
        tclEvalFmt("wm attributes %s -alpha %s", _name, alpha);
    }

    /** Place the window in a mode that takes up the entire screen. */
    void maximizeWindow()
    {
        tclEvalFmt("wm attributes %s -fullscreen 1", _name);
    }

    /** Restore the maximized window back to its original size. */
    void unmaximizeWindow()
    {
        tclEvalFmt("wm attributes %s -fullscreen 0", _name);
    }

    /** Minimize the window. */
    void minimizeWindow()
    {
        tclEvalFmt("wm iconify %s", _name);
    }

    /** Restore the minimized window. */
    void unminimizeWindow()
    {
        tclEvalFmt("wm deiconify %s", _name);
    }

    /** Return true if this window is minimized. */
    bool isMinimized()
    {
        return tclEvalFmt("wm state %s", _name) == "iconic";
    }

    /** Note: Minimized windows don't behave nicely with respect to setting their stacking order. */

    /** Make this the top-most window which will be displayed above all other windows. */
    void setTopWindow()
    {
        tclEvalFmt("raise %s", _name);
    }

    /** Make this the bottom-most window which will be displayed below all other windows. */
    void setBottomWindow()
    {
        tclEvalFmt("lower %s", _name);
    }

    /** Set this window above another window. */
    void setAbove(Window otherWindow)
    {
        tclEvalFmt("raise %s %s", _name, otherWindow._name);
    }

    /** Set this window below another window. */
    void setBelow(Window otherWindow)
    {
        tclEvalFmt("lower %s %s", _name, otherWindow._name);
    }

    /** Return true if this window is above another window. */
    bool isAbove(Window otherWindow)
    {
        return tclEvalFmt("wm stackorder %s isabove %s", _name, otherWindow._name) == "1";
    }

    /** Return true if this window is below another window. */
    bool isBelow(Window otherWindow)
    {
        return tclEvalFmt("wm stackorder %s isbelow %s", _name, otherWindow._name) == "1";
    }

    /** Return an array of all child widgets. */
    @property Widget[] childWidgets()
    {
        return walkChildWidgets.array;
    }

    /** Lazily return a range of all child widgets. */
    @property auto walkChildWidgets()
    {
        string paths = tclEvalFmt("winfo children %s", _name);
        return map!(a => Widget.lookupWidgetPath(a))(paths.arr_splitter);
    }

    /** Return the parent window of this window, or $(D null) if this window is the main window. */
    @property Window parentWindow()
    {
        string windowPath = tclEvalFmt("winfo parent %s", _name);
        return cast(Window)Widget.lookupWidgetPath(windowPath);
    }

    /** Get the menu bar, or $(D null) if one isn't set for this window. */
    @property MenuBar menubar()
    {
        auto menubar = this.getOption!string("menu");
        return cast(MenuBar)Widget.lookupWidgetPath(menubar);
    }

    /** Set a menu bar for this window. */
    @property void menubar(MenuBar newMenuBar)
    {
        this.setOption("menu", newMenuBar._name);
    }

    /**
        Create the menu bar for this window, and return it.
    */
    MenuBar createMenuBar()
    {
        auto menuBar = new MenuBar(this);
        this.setOption("menu", menuBar._name);
        return menuBar;
    }

    /** Get the context menu, or $(D null) if one isn't set for this window. */
    @property MenuBar contextMenu()
    {
        return _contextMenu;
    }

    /** Set a context menu for this window. */
    @property void contextMenu(MenuBar newContextMenu)
    {
        // todo: if the menu is already parented to this widget, we should not call
        // init parent. This means we need a more sophisticated parenting check mechanism,
        // and also to think about reparenting.
        // note: for now we'll ignore reparenting and only check if the widget has already
        // been parented.

        // todo: implement
        assert(0);
        /+ if (!newContextMenu._isInitialized)
            newContextMenu.initParent(this);

        assert(!newContextMenu._name.empty);

        version (OSX)
        {
            // right click on osx => second mouse button => context menu
            tclEvalFmt(`bind %s <2> "tk_popup %s %s"`, _name, newContextMenu._name, "%X %Y");

            // ctrl+left click on osx => context menu
            tclEvalFmt(`bind %s <Control-1> "tk_popup %s %s"`, _name, newContextMenu._name, "%X %Y");
        }
        else
        {
            tclEvalFmt(`bind %s <3> "tk_popup %s %s"`, _name, newContextMenu._name, "%X %Y");
        }

        _contextMenu = newContextMenu; +/
    }

private:
    MenuBar _contextMenu;
    Sizegrip _sizegrip;
}

/** Position the window to the center of the desktop. */
void centerWindow(Window window)
{
    auto winSize = window.size;
    auto scrSize = window.screenSize;
    window.position = Point((scrSize.width - winSize.width) / 2,
                            (scrSize.height - winSize.height) / 2);
}

private string toEvalString(Rect geometry)
{
    string width = to!string(geometry.width);
    string height = to!string(geometry.height);

    string xOffset = format("+%s", geometry.x);
    string yOffset = format("+%s", geometry.y);

    return format("%sx%s%s%s", width, height, xOffset, yOffset);
}

//
unittest
{
    assert(Rect(88, -88, 200, 200).toEvalString == "200x200+88+-88");
    assert(Rect(-88, 88, 200, 200).toEvalString == "200x200+-88+88");
    assert(Rect(88, 88, 200, 200).toEvalString  == "200x200+88+88");
}
