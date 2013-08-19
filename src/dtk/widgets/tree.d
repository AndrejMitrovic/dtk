/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.tree;

import std.array;
import std.conv;
import std.exception;
import std.range;
import std.string;

import dtk.geometry;
import dtk.utils;
import dtk.options;

import dtk.widgets.widget;

///
class Tree : Widget
{
    ///
    this(Widget master)
    {
        super(master, TkType.tree);
    }
}
