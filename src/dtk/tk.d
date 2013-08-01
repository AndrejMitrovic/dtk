/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tk;

// todo: move to some 'main' or 'widget' module

import std.stdio;
import std.c.stdlib;

import std.exception;
import std.string;
import std.conv;
import std.path;

import dtk.widget;
import dtk.tcl;
import dtk.event;

class Tk : Widget
{
    this()
    {
        m_interp = enforce(Tcl_CreateInterp());

        if (Tcl_Init(m_interp) != TCL_OK || Tk_Init(m_interp) != TCL_OK)
        {
            if (*m_interp.result)
            {
                stderr.writeln(to!string(m_interp.result));
            }

            .exit(1);  // todo: replace with exceptions for stack-unwinding
        }

        m_window = Tk_MainWindow(m_interp);

        if (m_window == null)
        {
            stderr.writeln(to!string(m_interp.result));
            .exit(1);  // todo: replace with exceptions for stack-unwinding
        }
    }

    // Finalizer error: InvalidMemoryOperationError
    // workaround: call exit() after Tk_MainLoop is done.
    ~this()
    {
        //~ Tcl_DeleteInterp(m_interp);
    }

    override void exit()
    {
        Tcl_DeleteInterp(m_interp);
    }

    void exit(Widget, Event)
    {
        Tcl_DeleteInterp(m_interp);
    }

    void mainloop()  // todo: replace with run()
    {
        Tk_MainLoop();
        this.exit();
    }

protected:
    Tk_Window m_window;
}
