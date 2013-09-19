/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.entry;

import std.exception;
import std.range;
import std.traits;
import std.typetuple;

import dtk.app;
import dtk.dispatch;
import dtk.event;
import dtk.geometry;
import dtk.interpreter;
import dtk.signals;
import dtk.types;
import dtk.utils;

import dtk.widgets.button;
import dtk.widgets.widget;

/** Check whether type $(D T) is a validator function. */
template isValidator(T)
{
    enum isValidator = isSomeFunction!T &&
                       is(ReturnType!T == IsValidated) &&
                       is(ParameterTypeTuple!T == TypeTuple!(Widget, ValidateEvent));
}

///
enum ValidationMode
{
    none,       ///
    focus,      ///
    focusIn,    ///
    focusOut,   ///
    key,        ///
    all,        ///
}

package ValidationMode toValidationMode(string input)
{
    switch (input) with (ValidationMode)
    {
        case "none":     return none;
        case "focus":    return focus;
        case "focusin":  return focusIn;
        case "focusout": return focusOut;
        case "key":      return key;
        case "all":      return all;
        default:         assert(0, format("Unhandled validation input: '%s'", input));
    }
}

///
class Entry : Widget
{
    ///
    this(Widget master)
    {
        super(master, TkType.entry, WidgetType.entry);

        _entryVar = makeVar();
        tclEvalFmt(`trace add variable %s write { %s %s %s $%s }`, _entryVar, _dtkCallbackIdent, EventType.entry, _name, _entryVar);
        this.setOption("textvariable", _entryVar);

        //~ enum string validationArgs = "%d %i %P %s %S %v %V";

        //~ tclEvalFmt("%s configure -validatecommand %s", _name,
            //~ format(`"%s %s %s %s %s"`,
                //~ _dtkCallbackIdent,
                //~ EventType.validate,
                //~ _name, validationArgs));
    }

    /**
        Signal emitted when validation is requested.
    */
    //~ public Signal!ValidateEvent onValidateEvent;

    /**
        Signal emitted when the entry text has changed.
    */
    public Signal!EntryEvent onEntryEvent;

    /** Return the text in this entry. */
    @property string value()
    {
        return tclGetVar!string(_entryVar);
    }

    /**
        Set the text in this entry.

        $(B Note:) If validation is enabled, the behavior of this
        function follows special rules according to the type of
        the validation. See $(D ValidateEvent) for more info.
    */
    @property void value(string newText)
    {
        tclSetVar(_entryVar, newText);
    }

    /**
        Get the char symbol that replaces the input characters
        when displayed in the entry. This is typically used for
        entries that input passwords where the char symbol could
        e.g. equal '*'. If no char symbol is set, ' ' is returned.
    */
    @property char displayChar()
    {
        string res = this.getOption!string("show");
        if (res.empty)
            return ' ';
        else
            return cast(char)res.front;
    }

    /**
        Set the char symbol that replaces the input characters
        when displayed in the entry.

        Note: Using ' ' will not re-set the display of characters,
        use resetDisplayChar instead.
    */
    @property void displayChar(char newDisplayChar)
    {
        this.setOption("show", newDisplayChar);
    }

    /** Reset the display of characters to normal. */
    void resetDisplayChar()
    {
        this.setOption("show", "");
    }

    /** Get the current validation mode for this entry. */
    @property ValidationMode validationMode()
    {
        return this.getOption!ValidationMode("validate");
    }

    /** Set the validation mode for this entry. */
    @property void validationMode(ValidationMode newValidationMode)
    {
        this.setOption("validate", to!string(newValidationMode));
    }

    /** Get the current justification. */
    @property Justification justification()
    {
        return this.getOption!string("justify").toJustification();
    }

    /** Set the justification. */
    @property void justification(Justification newJustification)
    {
        this.setOption("justify", newJustification.toString());
    }

private:
    string _entryVar;
}
