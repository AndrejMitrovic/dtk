/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.label;

import std.conv;
import std.string;

import dtk.color;
import dtk.geometry;
import dtk.utils;
import dtk.options;
import dtk.widget;

class Label : Widget
{
    this(Widget master)
    {
        DtkOptions options;
        super(master, "ttk::label", options);
    }

    @property Anchor anchor()
    {
        return this.getOption!string("anchor").toAnchor();
    }

    @property void anchor(Anchor newAnchor)
    {
        this.setOption("anchor", newAnchor.toString());
    }

    /**
        Get the current background color.

        Note: If the theme default background is used,
        RGB(0, 0, 0) is returned. Otherwise if the user
        set a new bgColor, it will be returned.
    */
    @property RGB bgColor()
    {
        return this.getOption!string("background").toRGB();
    }

    /** Set the background color. */
    @property void bgColor(RGB newRGB)
    {
        this.setOption("background", newRGB.toString());
    }

    /**
        Get the current foreground color.

        Note: If the theme default background is used,
        RGB(0, 0, 0) is returned. Otherwise if the user
        set a new bgColor, it will be returned.
    */
    @property RGB fgColor()
    {
        return this.getOption!string("foreground").toRGB();
    }

    /** Set the foreground color. */
    @property void fgColor(RGB newRGB)
    {
        this.setOption("foreground", newRGB.toString());
    }

    /** Get the current padding. */
    @property Padding padding()
    {
        return this.getOption!string("padding").toPadding;
    }

    /** Set the padding. */
    @property void padding(Padding newPadding)
    {
        this.setOption("padding", newPadding.toString);
    }

    /** Get the current justification. */
    @property Justification justification()
    {
        return this.getOption!string("justify").toJustification();
    }

    /** Set the padding. */
    @property void justification(Justification newJustification)
    {
        this.setOption("justify", newJustification.toString());
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

    /** Set a requested size for this label. */
    @property void size(Size newSize)
    {
        this.setOption("width", newSize.width);
        this.setOption("height", newSize.height);
    }

    /** Get the current requested size. */
    @property Size size()
    {
        Size result;
        result.width = this.getOption!int("width");
        result.height = this.getOption!int("height");
        return result;
    }
}
