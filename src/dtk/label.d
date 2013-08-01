/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.label;

import dtk.widget;
import dtk.options;

class Label : Widget
{
    this(Widget master, string text)
    {
        Options o;
        o["text"] = text;
        super(master, "label", o);
    }
}
