/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.event;

import std.string;

import dtk.entry;
import dtk.geometry;
import dtk.utils;

/** All possible Dtk events. */
enum EventType
{
    Invalid,  // sentinel
    Activate,
    Destroy,
    Map,
    ButtonPress,
    // Button,
    Enter,
    MapRequest,
    ButtonRelease,
    Expose,
    Motion,
    Circulate,
    FocusIn,
    MouseWheel,
    CirculateRequest,
    FocusOut,
    Property,
    Colormap,
    Gravity,
    Reparent,
    Configure,
    KeyPress,
    Key,
    ResizeRequest,
    ConfigureRequest,
    KeyRelease,
    Unmap,
    Create,
    Leave,
    Visibility,
    Deactivate,

    TkButtonPush,
    TkCheckButtonToggle,
    TkRadioButtonSelect,
    TkComboboxChange,
    TkTextChange,
    TkValidate,
    TkFailedValidation,
    TkListboxChange,
    TkProgressbarChange,
    TkScaleChange,
}

///
enum ValidationType
{
    preInsert,
    preDelete,
    revalidate
}

package ValidationType toValidationType(int input)
{
    switch (input) with (ValidationType)
    {
        case  1: return preInsert;
        case  0: return preDelete;
        case -1: return revalidate;
        default: assert(0, format("Unhandled validation type: '%s'", input));
    }
}

///
struct ValidateEvent
{
    /** type of validation action. */
    ValidationType type;

    /** index of character in string to be inserted/deleted, if any, otherwise -1. */
    sizediff_t charIndex;

    /**
        In prevalidation, the new value of the entry if the edit is accepted.
        In revalidation, the current value of the entry.
    */
    string newValue;

    /** The current value of entry prior to editing. */
    string curValue;

    /** The text string being inserted/deleted, if any, {} otherwise. */
    string changeValue;

    /** The current value of the validation mode for this widget. */
    ValidationMode validationMode;

    /**
        The validation condition that triggered the callback.
        If the validationMode is set to $(B all), validationCondition
        will contain the actual condition that triggered the
        validation (e.g. $(B key)).
    */
    ValidationMode validationCondition;
}

///
struct Event
{
    EventType type;

    int x;
    int y;
    int keycode;
    int character;
    int width;
    int height;
    int root_x;
    int root_y;
    string state;  // e.g. toggle state
    ValidateEvent validateEvent;
}

package enum EmitGenericSignals
{
    no,
    yes,
}
