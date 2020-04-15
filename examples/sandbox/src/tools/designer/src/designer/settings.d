/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module designer.settings;

import std.conv;
import std.exception;
import std.file;

import msgpack;

import dtk.geometry;

/**
    Stores all user settings for the designer:

    - Last main window geometry
*/
class Settings
{
    this(string fileName)
    {
        _fileName = fileName;
    }

    void load()
    {
        if (_fileName.exists)
        {
            ubyte[] buffer = cast(ubyte[])read(_fileName);
            msgpack.unpack(buffer, data);
        }
    }

    void save()
    {
        ubyte[] buffer = msgpack.pack(data);
        std.file.write(_fileName, buffer);
    }

    static struct Data
    {
        Rect mainWindowRect = Rect(100, 100, 100, 100);
    }

    Data data;
    alias data this;

private:
    const(string) _fileName;
}
