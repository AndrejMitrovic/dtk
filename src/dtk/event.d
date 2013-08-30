/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.event;

import std.string;
import std.traits;
import std.typetuple;

import dtk.geometry;
import dtk.utils;

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
private alias EventClassMap = TypeTuple!(Event, MouseEvent, KeyboardEvent);

/**
    Return the Event class type that matches the EventType specified.
    If the event type is a user event, the $(D Event) base class is returned.
*/
template toEventClass(EventType type)
{
    static assert(type != EventType.invalid,
        "Cannot retrieve event class type from uninitialized event type.");

    alias toEventClass = staticIndexOf!(cast(size_t)type, EventClassMap);
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

/**
    A single event handler. A user can assign a function or delegate
    event handler, a class with an $(D opCall) function, or a struct
    pointer with an $(D opCall) function. The event handler must take
    a single $(D EventClass) parameter with the $(D scope) storage class.

    $(D EventClass) is typically $(D Event) or one of its derived classes.

    Multiple assignment is possible, however each new assignment will
    remove any existing handler.

    Assigning $(D null) or calling $(D clear) will remove the event
    handler, and it will no longer be invoked when $(D call) is called.
*/
struct EventHandler(EventClass)
{
    /** Assign an event handler. */
    void opAssign(Handler)(Handler handler)  // note: typeof check due to overload matching issue
        if (is(typeof(isHandler!(Handler, EventClass))) && isHandler!(Handler, EventClass))
    {
        _callback = Callback(handler);
    }

    /** Clear the event handler. */
    void opAssign(typeof(null))
    {
        _callback.clear();
    }

    /** Ditto. */
    void clear()
    {
        _callback.clear();
    }

    /**
        Call the event handler with the $(D event).
        If no event handler was set, the function
        returns early.
    */
    void call(scope EventClass event)
    {
        if (_callback.deleg)
            _callback.deleg(event);
        else
        if (_callback.func)
            _callback.func(event);
    }

private:

    static struct Callback
    {
        this(T)(T handler)
        {
            static if (is(T == class))
            {
                static if (isDelegate!(typeof(&handler.opCall)))
                    this.deleg = cast(Deleg)&handler.opCall;
                else
                    this.func = cast(Func)&handler.opCall;
            }
            else
            static if (isPointer!T && is(pointerTarget!T == struct))
            {
                static if (isDelegate!(typeof(&pointerTarget!T.init.opCall)))
                    this.deleg = cast(Deleg)&handler.opCall;
                else
                    this.func = cast(Func)&handler.opCall;
            }
            else
            static if (isDelegate!T)
            {
                this.deleg = cast(Deleg)handler;
            }
            else
            static if (isFunctionPointer!T)
            {
                this.func = cast(Func)handler;
            }
            else
            static assert(0);
        }

        alias Func  = void function(scope EventClass);
        alias Deleg = void delegate(scope EventClass);

        Deleg deleg;
        Func func;

        void clear()
        {
            if (deleg !is null)
                deleg = null;

            if (func !is null)
                func  = null;
        }
    }

    alias stcType = ParameterStorageClass;
    alias storages = ParameterStorageClassTuple;

    /** Check whether $(D T) is a handler function which can be called with the $(D Types). */
    template isHandler(T, Types...)
        if (isSomeFunction!T)
    {
        enum bool isHandler = is(typeof(T.init(Types.init))) &&
                              storages!(T)[0] == stcType.scope_ &&
                              is(ReturnType!T == void);
    }

    /** Check whether $(D T) is a pointer to a struct with an $(D opCall) function which can be called with the $(D Types). */
    template isHandler(T, Types...)
        if (isPointer!T && is(pointerTarget!T == struct))
    {
        enum bool isHandler = is(typeof(pointerTarget!T.init.opCall(Types.init))) &&
                              storages!(pointerTarget!T.init.opCall)[0] == stcType.scope_ &&
                              is(ReturnType!T == void);
    }

    /** Check whether $(D T) is a class with an $(D opCall) function which can be called with the $(D Types). */
    template isHandler(T, Types...)
        if (is(T == class))
    {
        // we need a static if due to eager logical 'and' operator semantics
        static if (is(typeof(T.init.opCall(Types.init))))
        {
            enum bool isHandler = is(typeof(T.init.opCall(Types.init)) == void) &&
                                  storages!(T.init.opCall)[0] == stcType.scope_;
        }
        else
        {
            enum bool isHandler = false;
        }
    }

private:
    Callback _callback;
}

///
unittest
{
    import core.exception;
    import std.exception;

    static class MyEvent
    {
        this(int x, int y)
        {
            this.x = x;
            this.y = y;
        }

        int x;
        int y;
    }

    EventHandler!MyEvent handler;

    bool hasDgRun;
    auto event = scoped!MyEvent(1, 2);

    static assert(!is(typeof( handler = 1 )));
    static assert(!is(typeof( handler = () { } )));
    static assert(!is(typeof( handler = (MyEvent event) { } )));
    static assert(is(typeof( handler = (scope MyEvent event) { } )));

    struct SF1 { void opCall() { } }
    struct SF2 { void opCall(MyEvent event) { } }
    struct SK1 { void opCall(scope MyEvent event) { hasDgRun = true; assert(event.x == 1 && event.y == 2); } }
    struct SK2 { static void opCall(scope MyEvent event) { assert(event.x == 1 && event.y == 2); } }

    SF1 sf1;
    SF2 sf2;
    SK1 sk1;
    SK2 sk2;

    static assert(!is(typeof( handler = sf1 )));
    static assert(!is(typeof( handler = sf2 )));
    static assert(!is(typeof( handler = sk1 )));
    static assert(!is(typeof( handler = sk2 )));

    static assert(!is(typeof( handler = &sf1 )));
    static assert(!is(typeof( handler = &sf2 )));
    static assert(is(typeof( handler = &sk1 )));
    static assert(is(typeof( handler = &sk2 )));

    class CF1 { void opCall() { } }
    class CF2 { void opCall(MyEvent event) { } }
    class CK1 { void opCall(scope MyEvent event) { hasDgRun = true; assert(event.x == 1 && event.y == 2); } }
    class CK2 { static void opCall(scope MyEvent event) { assert(event.x == 1 && event.y == 2); } }

    CF1 cf1;
    CF2 cf2;
    CK1 ck1 = new CK1();
    CK2 ck2 = new CK2();

    static assert(!is(typeof( handler = cf1 )));
    static assert(!is(typeof( handler = cf2 )));
    static assert(is(typeof( handler = ck1 )));
    static assert(is(typeof( handler = ck2 )));

    /* test delegate lambda. */
    handler = (scope MyEvent event) { hasDgRun = true; assert(event.x == 1 && event.y == 2); };
    handler.call(event);
    assert(hasDgRun == true);

    hasDgRun = false;
    handler = null;
    handler.call(event);
    assert(!hasDgRun);

    /* test function lambda. */
    handler = function void(scope MyEvent event) { assert(event.x == 1 && event.y == 2); };
    handler.call(event);
    event.x = 2;
    assertThrown!AssertError(handler.call(event));

    /* test struct opCall. */
    event.x = 1;
    hasDgRun = false;
    handler = &sk1;
    handler.call(event);
    assert(hasDgRun);

    hasDgRun = false;
    handler = &sk2;
    handler.call(event);
    assert(!hasDgRun);

    event.x = 2;
    assertThrown!AssertError(handler.call(event));

    /* test class opCall. */
    event.x = 1;
    hasDgRun = false;
    handler = ck1;
    handler.call(event);
    assert(hasDgRun);

    hasDgRun = false;
    handler = ck2;
    handler.call(event);
    assert(!hasDgRun);

    event.x = 2;
    assertThrown!AssertError(handler.call(event));
}

/** Old code below */

//~ import dtk.widgets.entry;

//~ /** All possible Dtk events. */
//~ enum EventType
//~ {
    //~ Invalid,  // sentinel
    //~ Activate,
    //~ Destroy,
    //~ Map,
    //~ ButtonPress,
    //~ // Button,
    //~ Enter,
    //~ MapRequest,
    //~ ButtonRelease,
    //~ Expose,
    //~ Motion,
    //~ Circulate,
    //~ FocusIn,
    //~ MouseWheel,
    //~ CirculateRequest,
    //~ FocusOut,
    //~ Property,
    //~ Colormap,
    //~ Gravity,
    //~ Reparent,
    //~ Configure,
    //~ KeyPress,
    //~ Key,
    //~ ResizeRequest,
    //~ ConfigureRequest,
    //~ KeyRelease,
    //~ Unmap,
    //~ Create,
    //~ Leave,
    //~ Visibility,
    //~ Deactivate,

    //~ TkButtonPush,
    //~ TkCheckButtonToggle,
    //~ TkRadioButtonSelect,
    //~ TkComboboxChange,
    //~ TkTextChange,
    //~ TkValidate,
    //~ TkFailedValidation,
    //~ TkListboxChange,
    //~ TkProgressbarChange,
    //~ TkScaleChange,
    //~ TkSpinboxChange,
    //~ TkMenuItemSelect,
    //~ TkCheckMenuItemToggle,
    //~ TkRadioMenuSelect,
//~ }

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

// todo: remove this
enum EmitGenericSignals
{
    no,
    yes,
}
