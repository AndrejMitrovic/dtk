/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widget;

import std.stdio;
import std.string;
import std.c.stdlib;
import std.conv;

import dtk.options;
import dtk.event;
import dtk.callback;
import dtk.utils;
import dtk.tcl;

public const string HORIZONTAL = "horizontal";
public const string VERTICAL   = "vertical";

/**
   The main class for all DTK widgets.
*/
class Widget
{
    // todo: insert writeln's here to figure out what syntax is called
    this(Widget master, string wname, Options opt)
    {
        if (master.m_name == ".")
            m_name = "." ~ wname ~ to!string(m_cur_widget);
        else
            m_name = master.m_name ~ "." ~ wname ~ to!string(m_cur_widget);

        m_cur_widget++;
        m_interp = master.m_interp;

        stderr.writefln("tcl_eval { %s }", wname ~ " " ~ m_name ~ " " ~ options2string(opt));
        Tcl_Eval(m_interp, cast(char*)toStringz(wname ~ " " ~ m_name ~ " " ~ options2string(opt)));
    }

    this(Widget master, string wname, Options opt, Callback c)
    {
        m_cur_widget++;  // todo: this should be shared
        m_interp = master.m_interp;
        int  num  = addCallback(this, c);
        auto mopt = opt;
        mopt["command"] = "" ~ callbackPrefix ~ to!string(num) ~ "";

        if (master.m_name == ".")
            m_name = "." ~ wname ~ to!string(m_cur_widget);
        else
            m_name = master.m_name ~ "." ~ wname ~ to!string(m_cur_widget);

        stderr.writefln("tcl_eval { %s }", wname ~ " " ~ m_name ~ " " ~ options2string(mopt));
        Tcl_Eval(m_interp, cast(char*)toStringz(wname ~ " " ~ m_name ~ " " ~ options2string(mopt)));
    }

    this()
    {
        m_name = ".";
    }

    string name() const
    {
        return m_name;
    }

    void exit()
    {
    }

    Tcl_Interp* interp()
    {
        return m_interp;
    }

    void pack()
    {
        eval("pack " ~ m_name);
    }

    string pack(string a1, string a2, string args ...)
    {
        string a = "-" ~ a1 ~ " " ~ a2;

        if (args.length >= 2)
            return a ~ " " ~ args;
        else
            return eval("pack  " ~ m_name ~ " " ~ a);
    }

    string eval(string cmd)
    {
        stderr.writefln("tcl_eval { %s }", cmd);

        Tcl_Eval(m_interp, cast(char*)toStringz(cmd));
        return to!string(m_interp.result);
    }

    string cget(string key)
    {
        return eval(" cget -" ~ key);
    }

    string configure(string key, string value)
    {
        return eval(" configure -" ~ key ~ " " ~ value);
    }

    void cfg(Options o)
    {
        foreach (k, v; o)
            this.configure(k, v);
    }

    void clean()
    {
    }

    void bind(string event, Callback cb)
    {
        int num = addCallback(this, cb);
        writeln(eval(" bind " ~ m_name ~ " " ~ event ~ " {" ~ callbackPrefix ~ to!string(num) ~ " %x %y %k %K %w %h %X %Y}"));
    }

protected:
    Tcl_Interp* m_interp;

    /** Unique widget name. */
    string m_name = "";

    /** Counter to create a unique widget name. */
    static int m_cur_widget = 0;
}
