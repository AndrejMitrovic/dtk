/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.separator;

import dtk.app;
import dtk.event;
import dtk.geometry;
import dtk.imports;
import dtk.types;
import dtk.utils;

import dtk.widgets.widget;

///
class Separator : Widget
{
    ///
    this(Widget parent, Angle angle)
    {
        super(parent, TkType.separator, WidgetType.separator);
        this.setOption("orient", to!string(angle));
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
