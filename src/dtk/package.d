/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk;

public
{
    import dtk.app;
    import dtk.color;
    import dtk.event;
    import dtk.font;
    import dtk.geometry;
    import dtk.image;
    import dtk.interpreter;
    import dtk.keymap;
    import dtk.loader;
    import dtk.types;
    import dtk.utils;

    import dtk.widgets;
}

version(unittest)
version(DTK_UNITTEST)
{
    import dtk.tests;
}
