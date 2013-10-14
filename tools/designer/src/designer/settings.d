/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module designer.settings;

import std.conv;
import std.exception;

import dtk.geometry;

/**
    Stores all user settings for the designer:

    - Last main window geometry
*/
class Settings
{
    Rect mainWindowRect = Rect(100, 100, 100, 100);
}
