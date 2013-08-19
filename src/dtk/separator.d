/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.separator;

import std.conv;
import std.string;
import std.range;

import dtk.app;
import dtk.event;
import dtk.geometry;
import dtk.options;
import dtk.utils;
import dtk.widget;

///
class Separator : Widget
{
    ///
    this(Widget master, Orientation orientation)
    {
        DtkOptions options;
        options["orient"] = to!string(orientation);
        super(master, TkType.separator, options, EmitGenericSignals.no);
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
