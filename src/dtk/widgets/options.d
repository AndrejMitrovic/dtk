/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.options;

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
    text,   /// Display text only.
    image,  /// Display the image only.
    center, /// Display the text centered on top of the image.
    top,    /// Display the text above of the text.
    bottom, /// Display the text below of the text.
    left,   /// Display the text to the left of the text.
    right,  /// Display the text to the right of the text.
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
