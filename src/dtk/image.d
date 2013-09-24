/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.image;

import std.exception;
import std.file;
import std.path;

import dtk.interpreter;
import dtk.utils;

import dtk.widgets.widget;

///
class Image : Widget
{
    this(string fileName)
    {
        enforce(fileName.exists, format("File name '%s' does not exist.", fileName.absolutePath));
        enforce(fileName.isFile, format("File name '%s' is not a file.", fileName.absolutePath));
        super(CreateFakeWidget.init, WidgetType.image);

        tclEvalFmt("image create photo %s -file %s", _name, fileName._tclEscape);
    }
}
