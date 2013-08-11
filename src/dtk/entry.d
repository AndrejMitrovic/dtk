/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.entry;

import std.conv;
import std.exception;
import std.range;
import std.string;
import std.traits;
import std.typetuple;

import dtk.app;
import dtk.button;
import dtk.event;
import dtk.geometry;
import dtk.signals;
import dtk.types;
import dtk.utils;
import dtk.options;
import dtk.widget;

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

ValidationMode toValidationMode(string input)
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

        /* Validation */
        _validateVar = this.createVariableName();
        createTclVariable(_validateVar);

        string callValidator = format("%s %s", _eventCallbackIdent, validationArgs);
        string validateFunc = format("validate_%s", this.createCallbackName());

        /**
            // Note: unreliable, { } gets removed for empty arguments.

            proc %s {type args} {
                array set arg $args
                %s $type {*}[array get arg]
                return $%s
            }
        */

        this.evalFmt(
            `
            proc %s {type args} {
                %s $type $args
                return $%s
            }
            `, validateFunc,
               _eventCallbackIdent,
               _validateVar);

        this.evalFmt("%s configure -validatecommand { %s %s %s }", _name, validateFunc, EventType.TkValidate, validationArgs);
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
        when displayed in the entry.

        Note: Using ' ' will not re-set the display of characters,
        use resetDisplayChar instead.
    */
    @property void displayChar(dchar newDisplayChar)
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
        return this.setOption("validate", to!string(newValidationMode));
    }

    /** Set the validator function */
    @property void validator(Validator)(Validator validator)
        if (isSomeFunction!Validator &&
            is(ReturnType!Validator == IsValidated) &&
            is(ParameterTypeTuple!Validator == TypeTuple!(Widget, ValidateEvent)))
    {
        // hook up the validator
        this.onEvent.connect(
        (Widget widget, Event event)
        {
            switch (event.type) with (EventType)
            {
                case TkValidate:
                    this.setValidState(validator(widget, event.validateEvent));
                    break;

                default:
            }
        });
    }

    private void setValidState(IsValidated isValidated)
    {
        this.evalFmt("set %s %s", _validateVar, cast(bool)isValidated);
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
