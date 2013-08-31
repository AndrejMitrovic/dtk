/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.event;

import std.string;
import std.traits;
import std.typecons;
import std.typetuple;

import dtk.geometry;
import dtk.signals;
import dtk.utils;

import dtk.widgets.widget;

/**
    All the possible event types. If the event is a custom user event type,
    the event type will equal to EventType.user.
*/
enum EventType
{
    /** sentinel, an EventType should never be left default-initialized. */
    invalid,

    /**
        Any user-derived events will automatically have this event type set.
        The $(D userType) field can be used for user-defined tagging of the event.
    */
    user,

    /**
        Mouse event, e.g. a mouse moved, its wheel was turned,
        or one of its buttons was clicked.
    */
    mouse,

    /**
        Keyboard event, e.g. a key or key sequence was pressed or released,
        or held long enough to trigger a key hold event.
    */
    keyboard,
}

// All standard event types are listed here, in the same order as EventType.
private alias EventClassMap = TypeTuple!(Event, Event, MouseEvent, KeyboardEvent);

/**
    Return the Event class type that matches the EventType specified.
    If the event type is a user event, the $(D Event) base class is returned.
*/
template toEventClass(EventType type)
{
    static assert(type != EventType.invalid,
        "Cannot retrieve event class type from uninitialized event type.");

    alias toEventClass = EventClassMap[cast(size_t)type];
}

///
unittest
{
    static assert(is(toEventClass!(EventType.user) == Event));
    static assert(is(toEventClass!(EventType.mouse) == MouseEvent));
    static assert(is(toEventClass!(EventType.keyboard) == KeyboardEvent));
}

/** The root class of all event types. */
class Event
{
    /**
        The default base class constructor is only called for user-derived events.
        It ensures the event type is initialized as a user event.

        It can optionally take a user event type tag.
    */
    this(long userType = 0)
    {
        this.type = EventType.user;
        this.userType = userType;
    }

    // Only library event classes can call this ctor.
    package this(EventType type)
    {
        this.type = type;
        this.userType = 0;
    }

    /**
        The type of this event. Use this to quickly determine the dynamic type of the event.
        You can use the $(D toEventClass) to get the class type based on a known event type.
    */
    public const(EventType) type;

    /**
        A user-defined value which is typically usedto tag the dynamic type of the user event.
        This field is empty when the event is not a user-event, but otherwise can equal any
        value the user specifies.
    */
    public const(long) userType;

    /**
        Event handlers can set this field to true to  stop the event propagation mechanism.
        An event which is currently sinking or bubbling will stop traveling,
        and other event handlers will not be invoked for this event.
    */
    public bool handled = false;

    /**
        Get the target widget of this event.
    */
    @property Widget widget()
    {
        return _targetWidget;
    }

private:

    /* The target widget for the event. */
    Widget _targetWidget;
}

class MouseEvent : Event
{
    this()
    {
        super(EventType.mouse);
    }
}

class KeyboardEvent : Event
{
    this()
    {
        super(EventType.keyboard);
    }
}

/** Old code below */

//~ import dtk.widgets.entry;

/** Tk event types. */
package enum TkEventType
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
    TkSpinboxChange,
    TkMenuItemSelect,
    TkCheckMenuItemToggle,
    TkRadioMenuSelect,
}

///
enum ValidationType
{
    preInsert,
    preDelete,
    revalidate
}

ValidationType toValidationType(int input)
{
    switch (input) with (ValidationType)
    {
        case  1: return preInsert;
        case  0: return preDelete;
        case -1: return revalidate;
        default: assert(0, format("Unhandled validation type: '%s'", input));
    }
}

//~ ///
//~ struct ValidateEvent
//~ {
    //~ /** type of validation action. */
    //~ ValidationType type;

    //~ /** index of character in string to be inserted/deleted, if any, otherwise -1. */
    //~ sizediff_t charIndex;

    //~ /**
        //~ In prevalidation, the new value of the entry if the edit is accepted.
        //~ In revalidation, the current value of the entry.
    //~ */
    //~ string newValue;

    //~ /** The current value of entry prior to editing. */
    //~ string curValue;

    //~ /** The text string being inserted/deleted, if any, {} otherwise. */
    //~ string changeValue;

    //~ /** The current value of the validation mode for this widget. */
    //~ ValidationMode validationMode;

    //~ /**
        //~ The validation condition that triggered the callback.
        //~ If the validationMode is set to $(B all), validationCondition
        //~ will contain the actual condition that triggered the
        //~ validation (e.g. $(B key)).
    //~ */
    //~ ValidationMode validationCondition;
//~ }

//~ ///
//~ struct Event
//~ {
    //~ EventType type;

    //~ int x;
    //~ int y;
    //~ int keycode;
    //~ int character;
    //~ int width;
    //~ int height;
    //~ int root_x;
    //~ int root_y;
    //~ string state;  // e.g. toggle state
    //~ ValidateEvent validateEvent;
//~ }
