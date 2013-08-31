/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.labelframe;

import std.conv;
import std.range;
import std.string;

import dtk.geometry;
import dtk.utils;

import dtk.widgets.widget;

///
class LabelFrame : Widget
{
    ///
    this(Widget master)
    {
        super(master, TkType.labelframe);
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

    /**
        Get the current anchor.
        Specifies where to place the label.
    */
    @property Anchor anchor()
    {
        return this.getOption!string("labelanchor").toAnchor();
    }

    /** Set the anchor. */
    @property void anchor(Anchor newAnchor)
    {
        this.setOption("labelanchor", newAnchor.toString());
    }

    /** Get the 0-based index of the underlined character, or -1 if no character is underlined. */
    @property int underline()
    {
        return this.getOption!int("underline");
    }

    /** Set the underlined character using a 0-based index. */
    @property void underline(int charIndex)
    {
        this.setOption("underline", charIndex);
    }

    /** Get the text string displayed in the widget. */
    @property string text()
    {
        return this.getOption!string("text");
    }

    /** Set the text string displayed in the widget. */
    @property void text(string newText)
    {
        this.setOption("text", newText);
    }

    /**
        Get the text width currently set.
        If no specific text width is set, 0 is returned,
        which implies a natural text width is used.
    */
    @property int textWidth()
    {
        string input = this.getOption!string("width");
        if (input.empty)
            return 0;

        return to!int(input);
    }

    /**
        Set the text space width. If greater than zero, specifies how much space
        in character widths to allocate for the text label. If less than zero,
        specifies a minimum width. If zero, the natural width of the text label is used.
    */
    @property void textWidth(int newWidth)
    {
        this.setOption("width", newWidth);
    }
}
