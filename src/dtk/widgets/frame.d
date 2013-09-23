/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.frame;

import std.string;

import dtk.geometry;
import dtk.types;
import dtk.utils;

import dtk.widgets.widget;

///
class Frame : Widget
{
    ///
    this(Widget parent)
    {
        super(parent, TkType.frame, WidgetType.frame);
    }

    /** Get the current width of the border. */
    @property int borderWidth()
    {
        return this.getOption!int("borderwidth");
    }

    /** Set the desired width of the border. */
    @property void borderWidth(int newBorderWidth)
    {
        this.setOption("borderwidth", newBorderWidth);
    }

    /** Get the current border style. */
    @property BorderStyle borderStyle()
    {
        return this.getOption!BorderStyle("relief");
    }

    /** Set the border style. */
    @property void borderStyle(BorderStyle newBorderStyle)
    {
        this.setOption("relief", newBorderStyle.text);
    }

    /** Get the current padding that's included inside the border. */
    @property Padding padding()
    {
        return this.getOption!string("padding").toPadding;
    }

    /** Set the padding that's included inside the border. */
    @property void padding(Padding newPadding)
    {
        this.setOption("padding", newPadding.toString);
    }

    /**
        Get the current requested Frame size. This often returns Size(0, 0)
        since a frame typically doesn't explicitly request a specific size.
    */
    @property Size size()
    {
        Size result;
        result.width = this.getOption!int("width");
        result.height = this.getOption!int("height");
        return result;
    }

    /**
        Set a requested size for this frame. Note that if the pack, grid, or
        other geometry managers are used to manage the children of the frame
        the geometry manager's requested size will normally take precedence
        over the frame widget's size.

        Todo: pack propagate and grid propagate can be used to change this.
    */
    @property void size(Size newSize)
    {
        this.setOption("width", newSize.width);
        this.setOption("height", newSize.height);
    }
}
