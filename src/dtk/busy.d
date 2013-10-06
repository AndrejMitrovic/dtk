/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.busy;

import dtk.interpreter;
import dtk.utils;

import dtk.widgets.widget;

// todo: doesn't seem to work properly, wait for tk NG post.
@disable Busy busy(Widget widget)
{
    return Busy(widget);
}

struct Busy
{
    /* todo: Add cursor support. */
    void hold()
    {
        tclEvalFmt("tk busy hold %s", _widget._name);

        // create a dummy widget to steal the focus
        _dummyLabel = format("%s.%s", _widget.rootWindow._name, Widget._dtkDummyWidget);
        tclEvalFmt("label %s", _dummyLabel);
        tclEvalFmt("focus %s", _dummyLabel);
        tclEvalFmt("update");

        _isHeld = true;
    }

    void release()
    {
        tclEvalFmt("tk busy forget %s", _widget._name);
        tclEvalFmt("destroy %s", _dummyLabel);
    }

    /*
    void setCursor() { }
    */

private:
    Widget _widget;
    bool _isHeld;
    string _dummyLabel;
}
