/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.separator;

import std.conv;
import std.string;
import std.range;

import dtk.app;
import dtk.event;
import dtk.geometry;
import dtk.utils;

import dtk.widgets.widget;

///
class Separator : Widget
{
    ///
    this(Widget master, Orientation orientation)
    {
        super(master, TkType.separator, EmitGenericSignals.no);
        this.setOption("orient", to!string(orientation));
    }

    /** Get the orientation of this scrollbar. */
    @property Orientation orientation()
    {
        return this.getOption!Orientation("orient");
    }

    /** Set the orientation of this scrollbar. */
    @property void orientation(Orientation newOrient)
    {
        this.setOption("orient", newOrient);
    }
}
