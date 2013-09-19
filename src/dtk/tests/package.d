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
    /* Generic events. */
    import dtk.tests.test_events_destroy;
    import dtk.tests.test_events_focus;
    import dtk.tests.test_events_geometry;
    import dtk.tests.test_events_hover;
    import dtk.tests.test_events_keyboard;
    import dtk.tests.test_events_mouse;

    /* Widget behavior and events. */
    import dtk.tests.test_button;
    import dtk.tests.test_checkbutton;
    import dtk.tests.test_combobox;
    import dtk.tests.test_dialog;
    import dtk.tests.test_entry;
    //~ import dtk.tests.test_frame;
    //~ import dtk.tests.test_image;
    //~ import dtk.tests.test_label;
    //~ import dtk.tests.test_labelframe;
    //~ import dtk.tests.test_listbox;
    //~ import dtk.tests.test_notebook;
    //~ import dtk.tests.test_panedwindow;
    //~ import dtk.tests.test_progressbar;
    //~ import dtk.tests.test_radiobutton;
    //~ import dtk.tests.test_separator;
    //~ import dtk.tests.test_slider;
    //~ import dtk.tests.test_spinbox;
    //~ import dtk.tests.test_sizegrip;
    //~ import dtk.tests.test_scrollbar;
    //~ import dtk.tests.test_text;
    //~ import dtk.tests.test_window;

    //~ import dtk.tests.test_app;  // todo: implement
    //~ import dtk.tests.test_widget;  // todo: implement

    // todo: Need to add more features to menus, like dynamic configuration of menu items.
    // import dtk.tests.test_menu;

    // todo: Need to implement context menus
    // import dtk.tests.test_contextmenu;
}
