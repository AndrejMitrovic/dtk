/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.entry;

import std.conv;
import std.exception;
import std.range;
import std.string;
import std.traits;
import std.typetuple;

import dtk.app;
import dtk.event;
import dtk.geometry;
import dtk.interpreter;
import dtk.options;
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
enum IsValidated
{
    no,   ///
    yes,  ///
}

///
class Entry : Widget
{
    ///
    this(Widget master)
    {
        super(master, TkType.entry);

        string varName = makeTracedVar(TkEventType.TkTextChange);
        this.setOption("textvariable", varName);

        /* Validation */
        _validateVar = this.createVariableName();
        createTclVariable(_validateVar);

        string callValidator = format("%s %s", _dtkCallbackIdent, validationArgs);
        string validateFunc = format("validate_%s", this.createCallbackName());

        /**
            // Note: unreliable, { } gets removed for empty arguments.

            proc %s {type args} {
                array set arg $args
                %s $type {*}[array get arg]
                return $%s
            }
        */

        tclEvalFmt(
            `
            proc %s {type args} {
                %s $type $args
                return $%s
            }
            `, validateFunc,
               _dtkCallbackIdent,
               _validateVar);

        tclEvalFmt("%s configure -validatecommand { %s %s %s }", _name, validateFunc, TkEventType.TkValidate, validationArgs);
        tclEvalFmt("%s configure -invalidcommand { %s %s %s }", _name, validateFunc, TkEventType.TkFailedValidation, validationArgs);
    }

    /** Return the text in this entry. */
    @property string value()
    {
        return tclEvalFmt("%s get", _name);
    }

    /** Set the text in this entry. */
    @property void value(string newText)
    {
        tclEvalFmt("%s delete 0 end", _name);
        tclEvalFmt(`%s insert 0 "%s"`, _name, newText);
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

    /** Set the function to use for validation. */
    @property void onValidation(Validator)(Validator validator)
        if (isValidator!Validator)
    {
        this.onEvent.connect(
            (Widget widget, Event event)
            {
                if (event.type == TkEventType.TkValidate)
                    this.setValidState(validator(widget, event.validateEvent));
            });
    }

    /** Set the function to invoke on a failed validation. */
    @property void onFailedValidation(Func)(Func func)
        if (isSomeFunction!Func && is(ParameterTypeTuple!Func == TypeTuple!(Widget, ValidateEvent)))
    {
        this.onEvent.connect(
            (Widget widget, Event event)
            {
                if (event.type == TkEventType.TkFailedValidation)
                    func(widget, event.validateEvent);
            });
    }

    private void setValidState(IsValidated isValidated)
    {
        tclEvalFmt("set %s %s", _validateVar, cast(bool)isValidated);
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
    string _validateVar;
}
