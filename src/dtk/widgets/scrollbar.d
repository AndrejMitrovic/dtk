/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.scrollbar;

import dtk.event;
import dtk.geometry;
import dtk.types;
import dtk.utils;
import dtk.widgets.widget;

import std.array;
import std.algorithm;
import std.conv;
import std.exception;
import std.format;

/**
    $(B Note): The list of supported target widget types for which a scrollbar can be set:

    - Canvas
    - Listbox
    - Text
    - Tree
*/
class Scrollbar : Widget
{
    ///
    this(Widget parent, Widget target, Angle angle)
    {
        enforce(_scrollbarWidgetTypes.canFind(target.widgetType),
            format("Cannot set a scrollbar on a widget of type '%s'. The supported widget types are: %s.",
                target.widgetType, _scrollbarWidgetTypes[].map!(to!string).join(", ")));

        super(parent, TkType.scrollbar, WidgetType.scrollbar);

        this.setOption("orient", to!string(angle));

        // note: super ctor must be called first to get the _name field
        target.setScrollbar(this);
    }

    /** Get the angle of this scrollbar. */
    @property Angle angle()
    {
        return this.getOption!Angle("orient");
    }

    /** Set the angle of this scrollbar. */
    @property void angle(Angle newOrient)
    {
        this.setOption("orient", newOrient);
    }
}
