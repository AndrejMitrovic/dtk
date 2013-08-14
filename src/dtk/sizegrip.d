/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.sizegrip;

import dtk.app;
import dtk.event;
import dtk.widget;
import dtk.window;

///
class Sizegrip : Widget
{
    ///
    package this(Window master)
    {
        super(master, TkType.sizegrip, EmitGenericSignals.no);
        App.evalFmt("pack %s -side right -anchor se", _name);
    }
}
