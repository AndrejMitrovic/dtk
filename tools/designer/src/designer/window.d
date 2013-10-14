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

import msgpack;

import dtk;

import designer.settings;

class DesignerWindow
{
    this(Window window)
    {
        _window = window;
        _settings = new Settings();
        _settingsFile = format(r"%s\%s", thisExePath.dirName, "designer.dat");

        _window.onDestroyEvent ~= &this.onClose;
        this.onLoad();
    }

    private void onLoad()
    {
        this.loadSettings();
        _window.geometry = _settings.mainWindowRect;
    }

    /**
        When the window is closed:

        - Save the window geometry to disk so its loaded in the
        same position when the app is started again.
    */
    private void onClose()
    {
        _settings.mainWindowRect = _window.geometry;
        stderr.writefln("Window geometry: %s.", _settings.mainWindowRect);
        this.saveSettings();
    }

    private void loadSettings()
    {
        if (_settingsFile.exists)
        {
            ubyte[] data = cast(ubyte[])read(_settingsFile);
            msgpack.unpack(data, _settings);
        }
    }

    private void saveSettings()
    {
        ubyte[] data = msgpack.pack(_settings);
        std.file.write(_settingsFile, data);
    }

private:
    Window _window;
    Settings _settings;
    const(string) _settingsFile;
}
