/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.dialog;

import std.conv;
import std.exception;
import std.range;
import std.string;

import dtk.app;
import dtk.button;
import dtk.event;
import dtk.signals;
import dtk.types;
import dtk.utils;
import dtk.options;
import dtk.widget;

///
class OpenFileDialog : Widget
{
    ///
    this(Widget master)
    {
        super(master, TkType.combobox);

        _varName = this.createTracedTaggedVariable(EventType.TkComboboxChange);
        this.setOption("textvariable", _varName);
    }

    /** */
    void show()
    {
    }
}
