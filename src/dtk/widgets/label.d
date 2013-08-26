/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.label;

import std.conv;
import std.range;
import std.string;

import dtk.color;
import dtk.geometry;
import dtk.options;
import dtk.utils;

import dtk.widgets.widget;

///
class Label : Widget
{
    ///
    this(Widget master)
    {
        super(master, TkType.label);
    }

    /**
        Get the current anchor.
        An anchor specifies how the information in the
        widget is positioned relative to the inner margins.
    */
    @property Anchor anchor()
    {
        return this.getOption!string("anchor").toAnchor();
    }

    /** Set the anchor. */
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
        Reset the background color to the theme default background color.
        Note that calls to bgColor will return RGB(0, 0, 0) after this call.
    */
    void bgColorReset()
    {
        this.setOption("background", "");
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

    /**
        Reset the foreground color to the theme default foreground color.
        Note that calls to fgColor will return RGB(0, 0, 0) after this call.
    */
    void fgColorReset()
    {
        this.setOption("foreground", "");
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

    /** Set the justification. */
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

    /** Get the current requested size. */
    @property Size size()
    {
        Size result;
        result.width = this.getOption!int("width");
        result.height = this.getOption!int("height");
        return result;
    }

    /** Set a requested size for this label. */
    @property void size(Size newSize)
    {
        this.setOption("width", newSize.width);
        this.setOption("height", newSize.height);
    }

    /**
        Get the current maximum line length before wrapping takes place.
        The wrapping length is measured in pixels.
        If no wrapping is enabled 0 is returned.
    */
    @property int wrapLength()
    {
        string input = this.getOption!string("wraplength");
        if (input.empty)
            return 0;

        return to!int(input);
    }

    /**
        Get the maximum line length before wrapping takes place.
        The wrapping length is measured in pixels.
        Wrapping will be enabled if newWrapLength is greater than 0.
    */
    @property void wrapLength(int newWrapLength)
    {
        this.setOption("wraplength", newWrapLength);
    }

    /**
        Return the current font used as a string.
        If the default font is used an empty string is returned.
    */
    @property string font()
    {
        return this.getOption!string("font");
    }

    /**
        Set the font.
        If an empty string is passed the default font will be used.
        To avoid hardcoding platform-specific fonts, you can use
        one of the fonts in the $(D GenericFont) enum.
    */
    @property void font(string newFont)
    {
        this.setOption("font", newFont);
    }
}
