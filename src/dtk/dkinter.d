/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.dkinter;

import dtk.event;
import dtk.options;
import dtk.widget;
import dtk.tk;

import dtk.label;
import dtk.entry;
import dtk.listbox;
import dtk.radiobutton;
import dtk.message;
import dtk.scale;
import dtk.button;
import dtk.spinbox;
import dtk.canvas;

class Text : Widget
{
    this(Widget master)
    {
        Options o;
        super(master, "text", o);
    }
}

class Frame : Widget
{
    this(Widget master)
    {
        Options o;
        super(master, "frame", o);
    }
}
