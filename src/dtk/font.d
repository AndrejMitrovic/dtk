/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.font;

///
enum GenericFont : string
{
    default_     = "TkDefaultFont",      /// The default for all GUI items not otherwise specified.
    text         = "TkTextFont",         /// Used for entry widgets, listboxes, etc.
    fixed        = "TkFixedFont",        /// A standard fixed-width font.
    menu         = "TkMenuFont",         /// The font used for menu items.
    heading      = "TkHeadingFont",      /// The font typically used for column headings in lists and tables.
    caption      = "TkCaptionFont",      /// A font for window and dialog caption bars.
    smallCaption = "TkSmallCaptionFont", /// A smaller caption font for subwindows or tool dialogs
    icon         = "TkIconFont",         /// A font for icon captions.
    tooltip      = "TkTooltipFont",      /// A font for tooltips.
}
