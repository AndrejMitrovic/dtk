/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module designer.main;

import std.stdio;

import dtk;

void main()
{
    auto app = new App;
    auto window = app.mainWindow;

    window.geometry = Rect(300, 300, 400, 400);

    window.onDestroyEvent ~= (scope DestroyEvent e)
    {
        stderr.writefln("Window geometry: %s.", window.geometry);
    };

    app.run();
}
