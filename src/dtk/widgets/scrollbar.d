/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.scrollbar;

import std.algorithm;
import std.exception;
import std.range;

import dtk.event;
import dtk.geometry;
import dtk.types;
import dtk.utils;

import dtk.widgets.widget;

/**
    $(B Note): The list of supported target widget types for which a scrollbar can be set:

    - Canvas
    - Entry
    - Listbox
    - Text
    - Tree
*/
class Scrollbar : Widget
{
    ///
    this(Widget parent, Widget target, Orientation orientation)
    {
        enforce(_scrollbarWidgetTypes.canFind(target.widgetType),
            format("Cannot set a scrollbar on a %s widget. The supported widget types are: %s.",
                target.widgetType, (cast(TkType[])_scrollbarWidgetTypes).join(", ")));

        super(parent, TkType.scrollbar, WidgetType.scrollbar);

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
