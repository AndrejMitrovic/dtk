/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.spinbox;

import dtk.options;
import dtk.widget;

class Spinbox : Widget
{
    this(Widget master)
    {
        DtkOptions o;
        o["from"] = "0";
        o["to"]   = "10";
        super(master, "spinbox", o);
    }

    string get()
    {
        return eval("get");
    }
}
