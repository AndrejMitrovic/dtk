/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.sizegrip;

import dtk.app;
import dtk.interpreter;
import dtk.event;
import dtk.imports;
import dtk.types;

import dtk.widgets.widget;
import dtk.widgets.window;

///
class Sizegrip : Widget
{
    ///
    package this(Window parent)
    {
        super(parent, TkType.sizegrip, WidgetType.sizegrip);
        tclEvalFmt("pack %s -side right -anchor se", _name);
    }
}
