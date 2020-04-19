/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.options;

import dtk.utils;

import std.format;

/**
    Holds various options that are used in multiple widget types.
*/

/**
    Specifies how to display the image relative to the text,
    in the case both text and an image are present in a widget.
*/
enum Compound
{
    none,   /// Display the image if present, otherwise the text.
    text,   /// Display the text only.
    image,  /// Display the image only.
    center, /// Position the image and the text centered.
    top,    /// Position the image above the text.
    bottom, /// Position the image below the text.
    left,   /// Position the image to the left of the text.
    right,  /// Position the image to the right of the text.
}

/**
    Specifies the type of selection mode a widget has.
*/
enum SelectMode
{
    single,        /// Allow only a single selection.
    multiple,      /// Allow multiple selections.
    old_single,    /// deprecated
    old_multiple,  /// deprecated
}

package SelectMode toSelectMode(string input)
{
    switch (input) with (SelectMode)
    {
        case "browse":     return single;
        case "extended":   return multiple;
        case "single":     return old_single;
        case "multiple":   return old_multiple;
        default:           assert(0, format("Unhandled select input: '%s'", input));
    }
}

package string toString(SelectMode selectMode)
{
    final switch (selectMode) with (SelectMode)
    {
        case single:        return "browse";
        case multiple:      return "extended";
        case old_single:    return "single";
        case old_multiple:  return "multiple";
    }
}
