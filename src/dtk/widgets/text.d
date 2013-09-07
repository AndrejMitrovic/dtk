/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.text;

import std.string;

import dtk.app;
import dtk.event;
import dtk.geometry;
import dtk.interpreter;
import dtk.types;
import dtk.utils;

import dtk.widgets.widget;

///
enum WrapMode
{
    none,       ///
    character,  ///
    word,       ///
}

///
class Text : Widget
{
    ///
    this(Widget master)
    {
        super(master, TkType.text, WidgetType.text);
    }

    /**
        Get the current screen size of the text widget, in characters and rows.
    */
    @property Size size()
    {
        Size result;
        result.width = this.getOption!int("width");
        result.height = this.getOption!int("height");
        return result;
    }

    /**
        Set a requested size for this text widget, in characters and rows.
    */
    @property void size(Size newSize)
    {
        this.setOption("width", newSize.width);
        this.setOption("height", newSize.height);
    }

    /** Get the current wrapping mode. */
    @property WrapMode wrapMode()
    {
        return this.getOption!string("wrap").toWrapMode();
    }

    /** Set the wrapping mode. */
    @property void wrapMode(WrapMode newWrapMode)
    {
        this.setOption("wrap", newWrapMode.toString());
    }

    /** Get the entire contents of the text widget. */
    @property string value()
    {
        // tk text automatically adds a newline at the end
        return tclEvalFmt("%s get 1.0 end-1c", _name);
    }

    /** Set the contents of the text widget. */
    @property void value(string newText)
    {
        tclEvalFmt("%s delete 1.0 end", _name);
        tclEvalFmt("%s insert 1.0 %s", _name, newText._tclEscape);
    }
}

package WrapMode toWrapMode(string input)
{
    switch (input) with (WrapMode)
    {
        case "none": return none;
        case "char": return character;
        case "word": return word;
        default:     assert(0, format("Unhandled wrap mode input: '%s'", input));
    }
}

package string toString(WrapMode wrapMode)
{
    final switch (wrapMode) with (WrapMode)
    {
        case none:      return "none";
        case character: return "char";
        case word:      return "word";
    }
}
