/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module designer.app;

import std.stdio;

import dtk.app;

import designer.settings;
import designer.window;

class DesignerApp
{
    this()
    {
        _app = new App();
        _window = new DesignerWindow(_app.mainWindow);
    }

    void run()
    {
        _app.run();
    }

private:
    App _app;
    DesignerWindow _window;
}
