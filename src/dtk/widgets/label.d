/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.label;

import dtk.color;
import dtk.image;
import dtk.imports;
import dtk.geometry;
import dtk.types;
import dtk.utils;

import dtk.widgets.options;
import dtk.widgets.widget;

///
class Label : Widget
{
    ///
    this(Widget parent, in char[] text = null)
    {
        super(parent, TkType.label, WidgetType.label);

        if (text.length)
            this.setOption("text", text);
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

    /// Convenience alias.
    alias backColor = bgColor;

    /**
        Reset the background color to the theme default background color.
        Note that calls to bgColor will return RGB(0, 0, 0) after this call.
    */
    void bgColorReset()
    {
        this.setOption("background", "");
    }

    /// Convenience alias.
    alias backColorReset = bgColorReset;

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

    /// Convenience alias.
    alias foreColor = fgColor;

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

    /**
        Get the image associated with this label,
        or null if no image was set.
    */
    @property Image image()
    {
        string imagePath = this.getOption!string("image");
        return cast(Image)Widget.lookupWidgetPath(imagePath);
    }

    /**
        Set an image for this label. If image is null,
        the label is reset to display text only.

        Note: Use the $(D compound) option to set whether
        both an image and text should be displayed.
    */
    @property void image(Image newImage)
    {
        this.setOption("image", newImage ? newImage._name : "");
    }

    /**
        Get the compound.

        Compound specifies how to display the image relative to the text,
        in the case both text and an image are present.
    */
    @property Compound compound()
    {
        return this.getOption!Compound("compound");
    }

    /**
        Set the compound.

        Compound specifies how to display the image relative to the text,
        in the case both text and an image are present.
    */
    @property void compound(Compound newCompound)
    {
        this.setOption("compound", newCompound);
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
