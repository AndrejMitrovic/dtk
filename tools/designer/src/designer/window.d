/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module designer.window;

import std.stdio;

import dtk;

class DesignerWindow
{
    this(Window window)
    {
        _window = window;
        window.onDestroyEvent ~= &onClose;
    }

private:

    void onClose()
    {
        stderr.writefln("Window geometry: %s.", _window.geometry);
    }

private:
    Window _window;
}
