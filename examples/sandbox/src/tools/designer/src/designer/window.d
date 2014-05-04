/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module designer.window;

import std.file;
import std.path;
import std.stdio;
import std.string;

import dtk;

import designer.settings;

class DesignerWindow
{
    this(Window window)
    {
        _window = window;

        string settingsFile = format(r"%s\%s", thisExePath.dirName, "designer.dat");
        _settings = new Settings(settingsFile);

        _window.onDestroyEvent ~= &release;
        initialize();
    }

    private void initialize()
    {
        _settings.load();
        _window.geometry = _settings.mainWindowRect;
    }

    /**
        Called after the window is closed.

        - Save the window geometry to disk so its loaded in the
        same position when the app is started again.
    */
    private void release()
    {
        _settings.mainWindowRect = _window.geometry;
        _settings.save();
    }

private:
    Window _window;
    Settings _settings;
}
