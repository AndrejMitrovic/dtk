/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.button;

import dtk.callback;
import dtk.options;
import dtk.widget;

class Button : Widget
{
    this(Widget master, string text, Callback callback)
    {
        Options o;
        o["text"] = text;
        super(master, "button", o, callback);
    }

    void flash()
    {
        eval("flash");
    }

    void tkButtonEnter()
    {
        pure_eval("tkButtonEnter " ~ m_name);
    }

    void tkButtonLeave()
    {
        pure_eval("tkButtonLeave " ~ m_name);
    }

    void tkButtonDown()
    {
        pure_eval("tkButtonDown " ~ m_name);
    }

    void tkButtonUp()
    {
        pure_eval("tkButtonUp " ~ m_name);
    }

    void tkButtonInvoke()
    {
        pure_eval("tkButtonInvoke " ~ m_name);
    }
}

class TTKButton : Widget
{
    this(Widget master, string text, Callback callback)
    {
        Options o;
        o["text"] = text;
        super(master, "ttk::button", o, callback);
    }

    void flash()
    {
        eval("flash");
    }

    void tkButtonEnter()
    {
        pure_eval("tkButtonEnter " ~ m_name);
    }

    void tkButtonLeave()
    {
        pure_eval("tkButtonLeave " ~ m_name);
    }

    void tkButtonDown()
    {
        pure_eval("tkButtonDown " ~ m_name);
    }

    void tkButtonUp()
    {
        pure_eval("tkButtonUp " ~ m_name);
    }

    void tkButtonInvoke()
    {
        pure_eval("tkButtonInvoke " ~ m_name);
    }
}
