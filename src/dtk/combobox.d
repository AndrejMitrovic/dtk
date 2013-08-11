/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.combobox;

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
class Combobox : Widget
{
    // todo: add validation

    this(Widget master)
    {
        DtkOptions options;
        string varName = this.createVariableName();
        options["textvariable"] = varName;
        super(master, "ttk::entry", options);

        string tracerFunc = format("tracer_%s", this.createCallbackName());

        // tracer used instead of -command
        this.evalFmt(
            `
            proc %s {varname args} {
                upvar #0 $varname var
                %s %s $var
            }
            `, tracerFunc, _eventCallbackIdent, EventType.TkTextChange);

        // hook up the tracer for this unique variable
        this.evalFmt(`trace add variable %s write "%s %s"`, varName, tracerFunc, varName);
    }

    /** Return the text in this entry. */
    @property string value()
    {
        return evalFmt("%s get", _name);
    }

    /** Set the text in this entry. */
    @property void value(string newText)
    {
        evalFmt("%s delete 0 end", _name);
        evalFmt(`%s insert 0 "%s"`, _name, newText);
    }

    /**
        Get the char symbol that replaces the input characters
        when displayed in the entry. This is typically used for
        entries that input passwords, where the char symbol could
        equal '*'. If no char symbol is set, ' ' is returned.
    */
    @property dchar displayChar()
    {
        string res = this.getOption!string("show");
        if (res.empty)
            return ' ';
        else
            return res.front;
    }

    /**
        Set the char symbol that replaces the input characters
        when displayed in the entry
    */
    @property void displayChar(dchar newDisplayChar)
    {
        this.setOption("show", newDisplayChar);
    }
}
