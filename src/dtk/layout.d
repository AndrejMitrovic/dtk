/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.layout;

import dtk.interpreter;
import dtk.widgets.widget;

// todo: this should be moved to a layout module
void pack(Widget widget)
{
    tclEvalFmt("pack %s", widget._name);
}
