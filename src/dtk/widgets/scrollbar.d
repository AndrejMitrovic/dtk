/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.scrollbar;

import std.conv;
import std.range;
import std.string;

import dtk.event;
import dtk.geometry;

import dtk.widgets.widget;

///
class Scrollbar : Widget
{
    ///
    this(Widget master, Widget target, Orientation orientation)
    {
        super(master, TkType.scrollbar);

        this.setOption("orient", to!string(orientation));

        // note: super ctor must be called first to get the _name field
        target.setScrollbar(this);
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
