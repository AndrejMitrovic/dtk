/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests;

version(unittest):
version(DTK_UNITTEST):

private
{
    /* Test generic events and event propagation. */
    import dtk.tests.events_generic;
    import dtk.tests.events_destroy;
    import dtk.tests.events_focus;
    import dtk.tests.events_geometry;
    import dtk.tests.events_hover;
    import dtk.tests.events_keyboard;
    import dtk.tests.events_mouse;

    /* Widget behavior and widget-specific events. */
    import dtk.tests.button;
    import dtk.tests.checkbutton;
    import dtk.tests.combobox;
    import dtk.tests.cursor;
    import dtk.tests.dialog;
    import dtk.tests.entry;
    import dtk.tests.frame;
    import dtk.tests.label;
    import dtk.tests.labelframe;
    import dtk.tests.listbox;
    import dtk.tests.notebook;
    import dtk.tests.pane;
    import dtk.tests.progressbar;
    import dtk.tests.radiobutton;
    import dtk.tests.separator;
    import dtk.tests.slider;
    import dtk.tests.spinbox;
    import dtk.tests.sizegrip;
    import dtk.tests.scrollbar;
    import dtk.tests.text;
    import dtk.tests.tree;
    import dtk.tests.window;

    /* Test geometry layout. */
    import dtk.tests.layout;

    /* Image. */
    import dtk.tests.image;

    // todo: Need to add more features to menus, like dynamic configuration of menu items.
    // import dtk.tests.menu;
    // import dtk.tests.contextmenu;

    // todo: Need to implement context menus
    // import dtk.tests.contextmenu;
}
