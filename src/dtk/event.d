/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.event;

import dtk.geometry;

import dtk.keymap;
import dtk.signals;
import dtk.types;
import dtk.utils;
import dtk.platform;
import dtk.widgets;

import std.conv;
import std.exception;
import std.format;
import std.range;
import std.traits;
import std.typetuple;

import core.time;

/**
    All the possible event types. If the event is a custom user event type
    the event type will be EventType.user.
*/
enum EventType
{
    /** sentinel, an EventType should never be left default-initialized. */
    invalid,

    /**
        Any user-derived or 3rd-party-derived events will have this event type set.
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

    /**
        An event emitted when a widget's size, position, or border width changes,
        and sometimes when it has changed position in the stacking order.
    */
    geometry,

    /** The mouse moved in or out of the area of a target widget. */
    hover,

    /** The widget was focused in or out. */
    focus,

    /** A widget is about to be destroyed. */
    destroy,

    /** A drag action of a drag and drop operation was initiated. */
    drag,

    /** A drop action of a drag and drop operation was initiated. */
    drop,

    /** A button widget event, e.g. a button widget was pressed. */
    button,

    /** A check button widget event, e.g. a check button widget was toggled on or off. */
    check_button,

    /** A menu item was selected. */
    menu,

    /** An item in a combobox widget was selected. */
    combobox,

    /** Text in an entry widget was changed. */
    entry,

    /** Validation event when a widget needs to validate some text. */
    validate,

    /** One or more items in a listbox widget were selected. */
    listbox,

    /** A radio button was selected in a radio group. */
    radio_button,

    /** A slider was moved to select a new item. */
    slider,

    /** A scalar spinbox value was changed. */
    scalar_spinbox,

    /** A list spinbox value was changed. */
    list_spinbox,
}

/**
    Each event is traveling in a direction, either from the root window of
    the target widget towards the target widget (sinking), or in the
    opposite direction (bubbling).
*/
enum EventTravel
{
    ///
    invalid,  // sentinel

    /// The event is going through the target widget's filter list.
    filter,

    /// The event is sinking from the toplevel parent towards the target widget.
    sink,

    /// The event has reached its target widget, and is now being handled by either
    /// onEvent and/or one of its specific event handlers such as onKeyboardEvent.
    target,

    /// The event was dispatched to the widget, and now event listeners are notified.
    notify,

    /// The event is bubbling upwards towards the toplevel window of this widget.
    bubble,

    // direct,  // todo
}

/** The root class of all event types. */
class Event
{
    /**
        This base class constructor is only called for user-derived events.
        It ensures the event type is initialized as a user event.
    */
    this(Widget targetWidget, TimeMsec timeMsec = 0)
    {
        this(targetWidget, EventType.user, timeMsec);
    }

    package this(Widget targetWidget, EventType type, TimeMsec timeMsec)
    {
        this.type = type;
        this.timeMsec = timeMsec;
        _targetWidget = targetWidget;
    }

    /**
        Get the timestamp when the event occured.
        The returned type is a $(D core.time.Duration) type.
        The time is relative to when the system started.

        See also: $(D timeMsec) to get the number of milliseconds.
    */
    @property Duration time()
    {
        return timeMsec.dur!"msecs";
    }

    /**
        The timestamp in milliseconds when the event occurred.
        The time is relative to when the system started.

        See also: $(D time) to get a $(D Duration) type.
    */
    public const(TimeMsec) timeMsec;

    /**
        The type of this event. Use this to quickly determine the dynamic type of the event.
        You can use the $(D toEventClass) to get the class type based on a known event type.
    */
    public const(EventType) type;

    /**
        Event handlers can set this field to true to stop the event propagation mechanism.
        An event which is currently sinking or bubbling will stop traveling,
        and other event handlers will not be invoked for this event.
    */
    public bool handled = false;

    /** Get the target widget of this event. */
    @property Widget widget()
    {
        return _targetWidget;
    }

    /** Return the current travel direction of this event. */
    @property EventTravel travel()
    {
        return _eventTravel;
    }

    /** Output the string representation of this event. */
    void toString(scope void delegate(const(char)[]) sink) { }

    /**
        Derived classes should call $(D toStringImpl(sink, this.tupleof))
        in their $(D toString) implementation.
    */
    protected final void toStringImpl(T...)(scope void delegate(const(char)[]) sink, T args)
    {
        sink(getClassName(this));
        sink("(");

        foreach (val; args)
        {
            sink(enquote(val));
            sink(", ");
        }

        sink(to!string(widget));
        sink(", ");
        //sink(format("%sm%ss", time.minutes, time.seconds));  // drey todo
        sink(")");
    }

package:

    /**
        The target widget for the event. Note that this isn't a const public field, since
        we want to allow modification to the widget but disallow modification to the
        event object itself. Use the $(D widget) property above.
    */
    Widget _targetWidget;

    /** The current travel direction of the event. */
    EventTravel _eventTravel;
}

private enum AnyModifier = 1 << 15;

/**
    A set of keyboard modifiers or active mouse buttons
    while another event was generated.

    Examples:
        - When the 'a' key is pressed, the shift keyboard modifier might be present.
        - When the left mouse button is pressed, the right mouse button might already
          be held down, in which case the right mouse button is the button modifier.

    Use the equality operator ($(D ==)) to explicitly check for modifier keys.
    It will return true only if the specified set of key modifiers is present
    and $(B no additional) modifiers are present.

    Use the $(D isDown) method to check for modifier keys without caring whether
    there are any other additional modifiers present.

    The binary $(D AND) operator ($(D &)) is a convenience that calls $(D isDown).

    Use the $(D isAnyDown) method to check multiple modifier key combinations.
    If any of them match, this method returns true.

    Example:
    -----
    // test if only the ctrl key is held down (other modifiers may _not_ be present)
    event.keyMod == KeyMod.ctrl;

    // test whether the control key was held (other modifiers _can_ be present)
    event.keyMod.isDown(KeyMod.ctrl);

    // ditto
    event.keyMod & KeyMod.ctrl;

    // test whether both the control and alt key were held.
    // note: this will not return true if only the ctrl key
    // or only the alt key is held.
    event.keyMod.isDown(KeyMod.ctrl + KeyMod.alt);

    // ditto
    event.keyMod & (KeyMod.ctrl + KeyMod.alt);

    // use binary assignment operators += and -= to add or remove modifiers
    KeyMod keys;
    keys += KeyMod.ctrl;
    keys += KeyMod.alt;
    keys += KeyMod.mouse_left;

    // test ctrl + alt + left mouse button
    event.keyMod.isDown(keys);

    // ditto
    event.keyMod & keys;

    // test only ctrl + alt
    event.keyMod.isDown(keys - KeyMod.mouse_left);

    // ditto
    event.keyMod & (keys - KeyMod.mouse_left);

    // test if any of a set of key modifiers is present:
    // check whether ctrl or ctrl+alt is held down (other modifiers can be present)
    event.keyMod.isAnyDown(KeyMod.ctrl, KeyMod.ctrl + KeyMod.alt);

    // Note: The above is different to the following check.
    // The following will not return true if only the ctrl key or
    // only the alt key is held down.
    event.keyMod.isDown(KeyMod.ctrl + KeyMod.alt);

    // ditto
    event.keyMod.isDown(KeyMod.ctrl) || event.keyMod.isDown(KeyMod.ctrl + KeyMod.alt);

    // ditto
    event.keyMod & KeyMod.ctrl || event.keyMod & (KeyMod.ctrl + KeyMod.alt);

    // explicitly check whether whether either ctrl or ctrl+alt are held down.
    // (other modifiers may _not_ be present)
    event.keyMod == KeyMod.ctrl || event.keyMod == KeyMod.ctrl + KeyMod.alt;
    -----
*/
struct KeyMod
{
    /** No key modifier. */
    enum KeyMod none = KeyMod(0);

    /** Control key. */
    enum KeyMod control = KeyMod(1 << 2);

    /** Convenience - equal to $(D control). */
    enum KeyMod ctrl = control;

    /** Alt key. */
    enum KeyMod alt = KeyMod(AnyModifier << 2);

    /** Convenience for OSX - equal to $(D alt). */
    enum KeyMod option = alt;

    /** Shift key. */
    enum KeyMod shift = KeyMod(1 << 0);

    /** Capslock key. */
    enum KeyMod capslock = KeyMod(1 << 1);

    /**
        The meta key is present on special keyboards,
        such as the MIT keyboard.
        See: http://en.wikipedia.org/wiki/Meta_key
    */
    enum KeyMod meta = KeyMod(AnyModifier << 1);

    /**
        $(BLUE Windows-specific.)

        The Extended modifier appears on events that are
        associated with the keys on the extended keyboard.
        On a US keyboard, the extended keys include the
        Alt and Control keys at the right of the keyboard,
        the cursor keys in the cluster to the left of the
        numeric pad, the NumLock key, the Break key, the
        PrintScreen key, and the forward slash '/' and
        Enter keys in the numeric keypad.
    */
    enum KeyMod extended = KeyMod(1 << 15);

    /**
        The following are similarly named as the members of the
        $(D MouseButton) enum, but have a "mouse_" prefix.

        $(BLUE Note): The integral values of these members
        are not the same as the ones in the $(D MouseButton)
        enum, do not attempt to cast between the two.
    */

    /** The left mouse button. */
    enum KeyMod mouse_button1 = KeyMod(1 << 8);

    /** Convenience - equal to $(D mouse_button1). */
    enum KeyMod mouse_left = mouse_button1;

    /** The middle mouse button. */
    enum KeyMod mouse_button2 = KeyMod(1 << 9);

    /** Convenience - equal to $(D mouse_button2). */
    enum KeyMod mouse_middle = mouse_button2;

    /** The right mouse button. */
    enum KeyMod mouse_button3 = KeyMod(1 << 10);

    /** Convenience - equal to $(D mouse_button3). */
    enum KeyMod mouse_right = mouse_button3;

    /** First additional button - hardware-dependent. */
    enum KeyMod mouse_button4 = KeyMod(1 << 11);

    /** Convenience - equal to $(D mouse_button4) */
    enum KeyMod mouse_x1 = mouse_button4;

    /** Second additional button - hardware-dependent. */
    enum KeyMod mouse_button5 = KeyMod(1 << 12);

    /** Convenience - equal to $(D mouse_button5) */
    enum KeyMod mouse_x2 = mouse_button5;

    __gshared string[long] _toName;

    typeof(this) opBinary(string op : "+")(typeof(this) rhs) const
    {
        return typeof(this)(value | rhs.value);
    }

    typeof(this) opBinary(string op : "-")(typeof(this) rhs) const
    {
        auto dup = cast(KeyMod)this;
        dup -= rhs;
        return cast(typeof(return))dup;
    }

    bool opBinary(string op : "&")(typeof(this) rhs) const
    {
        return isDown(rhs);
    }

    void opOpAssign(string op : "+")(typeof(this) rhs)
    {
        value |= rhs.value;
    }

    void opOpAssign(string op : "-")(typeof(this) rhs)
    {
        value ^= rhs.value;
    }

    // workaround for pretty printing
    string toString() const
    {
        string[] res;

        alias strings = TypeTuple!("ctrl", "alt", "shift", "capslock", "meta", "extended", "mouse_button1", "mouse_button2", "mouse_button3", "mouse_button4", "mouse_button5");

        foreach (idx, val; allKeyMods)
        {
            if (isDown(val))
                res ~= strings[idx];
        }

        if (res.empty)
            res ~= "none";

        return "KeyMod(%s)".format(res.join(" + "));
    }

    /** Check whether keyMod equals this keyMod. */
    bool isDown(typeof(this) keyMod) const
    {
        return (value & keyMod.value) == keyMod.value;
    }

    /** Check whether any of keyMods equals this keyMod. */
    bool isAnyDown(typeof(this)[] keyMods...) const
    {
        foreach (keyMod; keyMods)
        {
            if (isDown(keyMod))
                return true;
        }

        return false;
    }

    package long toTclValue()
    {
        return value;
    }

private:
    long value;

public:
    /** All known key modifiers. */
    alias allKeyMods = TypeTuple!(ctrl, alt, shift, capslock, meta, extended, mouse_button1, mouse_button2, mouse_button3, mouse_button4, mouse_button5);
}

unittest
{
    KeyMod mod;
    mod += KeyMod.control;
    mod -= KeyMod.control;
    mod += KeyMod.control;

    mod += KeyMod.alt;

    assert(mod.isDown(KeyMod.control));
    assert(mod.isDown(KeyMod.alt));
    assert(mod.isDown(KeyMod.control + KeyMod.alt));

    assert(mod.isDown(KeyMod.control));
    assert(mod.isDown(KeyMod.alt));

    KeyMod mod2 = KeyMod.ctrl + KeyMod.alt;
    assert(mod.isDown(mod2));

    assert(mod.isDown(KeyMod.control + KeyMod.alt));
    const alt = KeyMod.alt;
    assert(mod.isDown(KeyMod.control + alt));

    foreach (type; KeyMod.allKeyMods)
        mod += type;

    foreach (type; KeyMod.allKeyMods)
        mod -= type;
}

unittest
{
    KeyMod keyMod;

    // test if only the ctrl key is held down (other modifiers may not be present)
    keyMod = KeyMod.ctrl;
    assert(keyMod == KeyMod.ctrl);

    // test whether the control key was held (other modifiers can be present)
    keyMod += KeyMod.alt;
    assert(keyMod.isDown(KeyMod.ctrl));
    assert(keyMod & KeyMod.ctrl);

    // test whether both the control and alt key were held  (other modifiers can be present)
    keyMod += KeyMod.shift;
    assert(keyMod.isDown(KeyMod.ctrl + KeyMod.alt));
    assert(keyMod & (KeyMod.ctrl + KeyMod.alt));

    keyMod = KeyMod.ctrl;
    assert(!keyMod.isDown(KeyMod.ctrl + KeyMod.alt));
    assert(!(keyMod & (KeyMod.ctrl + KeyMod.alt)));

    keyMod = KeyMod.alt;
    assert(!keyMod.isDown(KeyMod.ctrl + KeyMod.alt));
    assert(!(keyMod & (KeyMod.ctrl + KeyMod.alt)));

    // can use binary operators + and - to add or remove modifiers
    KeyMod keys;
    keys += KeyMod.ctrl;
    keys += KeyMod.alt;
    keys += KeyMod.mouse_left;

    // test ctrl + alt + left mouse button
    keyMod = keys;
    assert(keyMod.isDown(keys));
    assert(keyMod & keys);

    keyMod -= KeyMod.ctrl;
    assert(!keyMod.isDown(keys));
    assert(!(keyMod & keys));

    // test ctrl + alt
    keyMod += KeyMod.ctrl;
    assert(keyMod.isDown(keys - KeyMod.mouse_left));
    assert(keyMod & (keys - KeyMod.mouse_left));

    // test if any of a set of key modifiers is present:
    // check whether ctrl or ctrl+alt is held down (other modifiers can be present)
    keyMod = KeyMod.ctrl;
    assert(keyMod.isAnyDown(KeyMod.ctrl, KeyMod.ctrl + KeyMod.alt));

    keyMod += KeyMod.shift;
    assert(keyMod.isAnyDown(KeyMod.ctrl, KeyMod.ctrl + KeyMod.alt));

    keyMod = KeyMod.ctrl + KeyMod.alt;
    assert(keyMod.isAnyDown(KeyMod.ctrl, KeyMod.ctrl + KeyMod.alt));
    assert(keyMod.isDown(KeyMod.ctrl) || keyMod.isDown(KeyMod.ctrl + KeyMod.alt));
    assert(keyMod & KeyMod.ctrl || keyMod & (KeyMod.ctrl + KeyMod.alt));

    keyMod = KeyMod.alt;
    assert(!keyMod.isAnyDown(KeyMod.ctrl, KeyMod.ctrl + KeyMod.alt));
    assert(!(keyMod.isDown(KeyMod.ctrl) || keyMod.isDown(KeyMod.ctrl + KeyMod.alt)));
    assert(!(keyMod & KeyMod.ctrl || keyMod & (KeyMod.ctrl + KeyMod.alt)));

    // explicitly check whether whether either ctrl or ctrl+alt is held down.
    // (other modifiers may not be present)
    keyMod = KeyMod.ctrl;
    assert(keyMod == KeyMod.ctrl || keyMod == KeyMod.ctrl + KeyMod.alt);

    keyMod = KeyMod.ctrl + KeyMod.alt;
    assert(keyMod == KeyMod.ctrl || keyMod == KeyMod.ctrl + KeyMod.alt);

    keyMod = KeyMod.ctrl + KeyMod.shift;
    assert(!(keyMod == KeyMod.ctrl || keyMod == KeyMod.ctrl + KeyMod.alt));
}

/** A set of possible mouse actions. */
enum MouseAction
{
    /** Sentinel. */
    none,

    /** One of the mouse buttons was pressed. */
    press = 1,

    /** One of the mouse buttons was released. */
    release = 2,

    /** Convenience - equal to $(D press). */
    click = press,

    /** One of the mouse buttons was clicked twice in rapid succession. */
    double_click = 3,

    /** One of the mouse buttons was clicked three times in rapid succession. */
    triple_click = 4,

    /** One of the mouse buttons was clicked four times in rapid succession. */
    quadruple_click = 5,

    /**
        The mouse wheel was moved. See the $(D wheel) field to determine
        the direction the mouse wheel was moved in.

        $(BLUE Note): When the wheel is pressed as a mouse button,
        the action will equal $(D press), not $(D wheel).
    */
    wheel = 6,

    /** The mouse was moved. */
    motion = 7,

    /** Convenience - equal to $(D motion) */
    move = motion,
}

/** A set of possible mouse buttons. */
enum MouseButton
{
    /** No button was pressed or released. */
    none = 0,

    /** The left mouse button. */
    button1 = 1,

    /** Convenience - equal to $(D button1). */
    left = button1,

    /** The middle mouse button. */
    button2 = 2,

    /** Convenience - equal to $(D button2). */
    middle = button2,

    /** The right mouse button. */
    button3 = 3,

    /** Convenience - equal to $(D button3). */
    right = button3,

    /** First additional button - hardware-dependent. */
    button4 = 4,

    /** Convenience - equal to $(D button4) */
    x1 = button4,

    /** Second additional button - hardware-dependent. */
    button5 = 5,

    /** Convenience - equal to $(D button5) */
    x2 = button5,
}

///
class MouseEvent : Event
{
    this(Widget widget, MouseAction action, MouseButton button, int wheel, KeyMod keyMod, Point widgetMousePos, Point desktopMousePos, TimeMsec timeMsec)
    {
        super(widget, EventType.mouse, timeMsec);
        this.action = action;
        this.button = button;
        this.wheel = wheel;
        this.keyMod = keyMod;
        this.widgetMousePos = widgetMousePos;
        this.desktopMousePos = desktopMousePos;
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /**
        Specifies what action the mouse performed,
        e.g. a button click, a mouse motion, etc.
    */
    const(MouseAction) action;

    /**
        Specifies which button, if any, was pressed,
        or released. If no buttons were pushed or
        released then it equals $(D MouseButton.none).
    */
    const(MouseButton) button;

    /**
        The delta when the mouse wheel has been scrolled.
        It is a positive value when pushed forward, and
        negative otherwise. It equals zero if the wheel
        was not scrolled.

        Note: The delta is hardware-specific, based on the
        hardware resolution of the mouse wheel. Typically
        it equals 120, 0, or -120, however this number can be
        arbitrary when the hardware supports finer-grained
        scrolling resolution.

        See also the MSDN article mentioning the mouse
        wheel delta here:
        http://msdn.microsoft.com/en-us/library/windows/desktop/ms645617%28v=vs.85%29.aspx
    */
    const(int) wheel;

    /**
        The set of key modifiers that were held when
        the mouse event was generated.
    */
    const(KeyMod) keyMod;

    /**
        The mouse position relative to the target widget
        when the mouse event was generated.
    */
    const(Point) widgetMousePos;

    /**
        The mouse position relative to the desktop
        when the mouse event was generated.
    */
    const(Point) desktopMousePos;
}

/**
    A set of possible keyboard actions.
*/
enum KeyboardAction
{
    /** Sentinel. */
    none,

    /** One of the keys was pressed. */
    press,

    /** One of the keys was released. */
    release,
}

///
class KeyboardEvent : Event
{
    this(Widget widget, KeyboardAction action, KeySym keySym, dchar unichar, KeyMod keyMod, Point widgetMousePos, Point desktopMousePos, TimeMsec timeMsec)
    {
        super(widget, EventType.keyboard, timeMsec);
        this.action = action;
        this.keySym = keySym;
        this.unichar = unichar;
        this.keyMod = keyMod;
        this.widgetMousePos = widgetMousePos;
        this.desktopMousePos = desktopMousePos;
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /**
        Specifies what action the keyboard performed,
        e.g. a key press, a key release, etc.
    */
    const(KeyboardAction) action;

    /**
        The key symbol that was pressed or released.
    */
    const(KeySym) keySym;

    /**
        The unicode character that was pressed or released.

        Note: this can equal $(D dchar.init) if only a
        single key modifier was pressed (e.g. $(B control) key).

        Note: when a modifier is pressed together with a key,
        e.g. $(B control + a) - this will store a
        control unicode character such as 'SUB' to $(D unichar),
        but $(D keySym) will equal the $(B 'a') key.

        On the other hand, pressing e.g. $(B shift + a) will
        set both $(D unichar) and $(D keySym) to $(B 'A').
    */
    const(dchar) unichar;

    /**
        The set of key modifiers that were held when
        the mouse event was generated.
    */
    const(KeyMod) keyMod;

    /**
        The mouse position relative to the target widget
        when the keyboard event was generated.
    */
    const(Point) widgetMousePos;

    /**
        The mouse position relative to the desktop
        when the keyboard event was generated.
    */
    const(Point) desktopMousePos;
}

///
class GeometryEvent : Event
{
    this(Widget widget, Point position, Size size, int borderWidth, TimeMsec timeMsec)
    {
        super(widget, EventType.geometry, timeMsec);
        this.position = position;
        this.size = size;
        this.borderWidth = borderWidth;
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /**
        Position of the target widget relative to its parent.
    */
    const(Point) position;

    /**
        The size of the widget.
    */
    const(Size) size;

    /**
        The border width of the widget.
    */
    const(int) borderWidth;
}

///
enum HoverAction
{
    /// Sentinel.
    none,

    /// The pointer entered the area of the target widget
    enter,

    /// The pointer left the area of the target widget
    leave,
}

///
class HoverEvent : Event
{
    this(Widget widget, HoverAction action, Point position, KeyMod keyMod, TimeMsec timeMsec)
    {
        super(widget, EventType.hover, timeMsec);
        this.action = action;
        this.position = position;
        this.keyMod = keyMod;
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /**
        Whether the pointer moved in our out of the area of the target widget.
    */
    const(HoverAction) action;

    /**
        Position of the mouse pointer relative to the target widget.
    */
    const(Point) position;

    /**
        The set of key modifiers that were held when
        the mouse event was generated.
    */
    const(KeyMod) keyMod;
}

///
enum FocusAction
{
    /// Sentinel
    none,

    /// A focus is requested for a widget.
    request,

    /// The widget was focused in (the focus has entered the widget).
    focus,

    /// The widget was focused out (the focus has left the widget).
    unfocus,
}

///
class FocusEvent : Event
{
    this(Widget widget, FocusAction action, TimeMsec timeMsec)
    {
        super(widget, EventType.focus, timeMsec);
        this.action = action;
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /**
        During a focus request, check or set whether we allow
        the target widget to be focused.

        Initially this property returns $(D true).

        $(B Note:) If the target widget has its $(D canFocus)
        property set to false, it overrides the value of the
        $(D allowFocus) property.

        This means focusing is a co-operative operation.
        Both the event handler (if any) and the target widget
        must allow the focus request for the the widget to be
        focused.

        $(B Note:) You may only access this property during a
        $(D FocusAction.request) action.
    */
    @property bool allowFocus()
    {
        checkAction();
        return _allowFocus;
    }

    /** ditto */
    @property void allowFocus(bool doAllow)
    {
        checkAction();
        _allowFocus = doAllow;
    }

    /**
        Whether the target widget was focused in or focused out.
    */
    const(FocusAction) action;

private:
    private void checkAction(string file = __FILE__, size_t line = __LINE__)
    {
        enforce(action == FocusAction.request,
            format("Cannot access the 'allowFocus' property during a '%s' action. Action must equal '%s'",
                action, FocusAction.request), file, line);
    }

package:
    bool _allowFocus = true;
}

///
class DestroyEvent : Event
{
    this(Widget widget, TimeMsec timeMsec)
    {
        super(widget, EventType.destroy, timeMsec);
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }
}

/// These actions occur during a drag & drop mouse operation.
enum DragAction
{
    none,      /// Sentinel
    keyChange, /// A key modifier was pressed/released or the escape key was pressed

    /**
        The user has dragged in/over/out of a target widget.

        $(B Note): During this event changing widget properties will not
        be immediately reflected in the GUI because the drag & drop
        is a modal operation.

        The only GUI operations that are immediately reflected are
        cursor changes.
    */
    feedback,

    drop,      /// The drag & drop operation is complete.
    canceled,  /// The drag & drop operation was cancelled.
}

package enum DragState
{
    proceed  = 0,
    cancel   = 0x00040101,
    dropData = 0x00040100,
}

enum DropEffect
{
	none   = 0,
	copy   = 1,
	move   = 2,
	link   = 3,
	scroll = 0x80000000,
}

class DragEvent : Event
{
    this(Widget widget, DragAction action, bool escapePressed, KeyMod keyMod, TimeMsec timeMsec)
    {
        super(widget, EventType.drag, timeMsec);
        this.action = action;
        _escapePressed = escapePressed;
        _keyMod = keyMod;
    }

    this(Widget widget, DragAction action, DropEffect dropEffect, TimeMsec timeMsec)
    {
        super(widget, EventType.drag, timeMsec);
        assert(action == DragAction.drop || action == DragAction.feedback, action.text);
        this.action = action;
        _dropEffect = dropEffect;
    }

    this(Widget widget, DragAction action, TimeMsec timeMsec)
    {
        super(widget, EventType.drag, timeMsec);
        assert(action != DragAction.keyChange, action.text);
        this.action = action;
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /** The action that triggered this drag event. */
    const(DragAction) action;

    /**
        A bit mask of key modifiers.

        $(B Note:) The modifiers supported during a drag and drop operation are:
        - control, alt, shift, mouse_left, mouse_middle, mouse_right.

        $(B Note:) You may only access this property during a
        $(D DragAction.keyChange) action.
    */
    @property KeyMod keyMod()
    {
        checkAction!(DragAction.keyChange);
        return _keyMod;
    }

    /**
        Check whether the escape key was pressed.

        $(B Note:) You may only access this property during a
        $(D DragAction.keyChange) action.
    */
    @property bool escapePressed()
    {
        checkAction!(DragAction.keyChange);
        return _escapePressed;
    }

    /**
        Cancel the drag & drop operation.

        $(B Note:) You may only call this function during a
        $(D DragAction.keyChange) action.
    */
    void cancel()
    {
        checkAction!(DragAction.keyChange);
        _dragState = DragState.cancel;
    }

    /**
        Attempt to drop the data to the current window the
        mouse is hovered over.s

        $(B Note:) You may only call this function during a
        $(D DragAction.keyChange) action.
    */
    void dropData()
    {
        checkAction!(DragAction.keyChange);
        _dragState = DragState.dropData;
    }

    /**
        Check whether the data was moved after a drop action.

        $(B Note:) You may only access this property during a
        $(D DragAction.drop) action.
    */
    @property bool hasMovedData()
    {
        checkAction!(DragAction.drop);
        return (_dropEffect & DropEffect.move) == DropEffect.move;
    }

    /**
        Check whether the data was copied after a drop action.

        $(B Note:) You may only access this property during a
        $(D DragAction.drop) action.
    */
    @property bool hasCopiedData()
    {
        checkAction!(DragAction.drop);
        return (_dropEffect & DropEffect.copy) == DropEffect.copy;
    }

private:
    private void checkAction(DragAction expectAction, string func = __FUNCTION__)
                            (string file = __FILE__, size_t line = __LINE__)
    {
        enum ident = func.unqualed();
        alias symbol = typeof(&mixin(ident));
        enum attrs = functionAttributes!symbol;

        static if (attrs & FunctionAttribute.property)
            enum fmt = "Cannot access the '" ~ ident ~ "' property during a '%s' action. Action must equal '" ~ expectAction.text ~ "'.";
        else
            enum fmt = "Cannot call the '" ~ ident ~ "' function during a '%s' action. Action must equal '" ~ expectAction.text ~ "'.";

        enforce(action == expectAction, format(fmt, action), file, line);
    }

package:
    DragState _dragState;

private:
    bool _escapePressed;
    KeyMod _keyMod;
    DropEffect _dropEffect;
}

/// These actions occur during a drag & drop mouse operation.
enum DropAction
{
    none,   /// Sentinel
    enter,  /// The mouse entered a widget's area.
    move,   /// The mouse moved within a widget's area.
    drop,   /// The mouse button was released, finishing the drag & drop operation.
    leave,  /// The mouse left a widget's area.
}

class DropEvent : Event
{
    this(Widget widget, DropAction action, DropData dropData, DropEffect dropEffect, Point position, KeyMod keyMod, TimeMsec timeMsec)
    {
        super(widget, EventType.drop, timeMsec);
        this.action = action;
        _dropData = dropData;
        _dropEffect = dropEffect;
        _position = position;
        _keyMod = keyMod;
    }

    this(Widget widget, DropAction action, TimeMsec timeMsec)
    {
        super(widget, EventType.drop, timeMsec);
        assert(action == DropAction.leave, action.text);
        this.action = action;
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /** The action that triggered this drag and drop event. */
    const(DropAction) action;

    /**
        The event handler should set this to true when it wants
        to accept the drag and drop event. The mouse cursor
        typically changes based on the value of this field.

        This value can be set in both the $(D enter) and $(D move)
        actions, allowing a technique of accepting the $(D drop)
        event based on the relative mouse position and the
        current key modifiers.

        Example:
        -----
        if (!event.hasData!string)
            return;  // return early if string type not found

        if (event.action == DropAction.enter
            || event.action == DropAction.move)
        {
            // only accept the drop in a specific area and
            // if the control key is held down
            if (event.position < Point(50, 50)
                && event.keyMod & KeyMod.control)
                event.acceptDrop = true;
        }
        else
        if (event.action == DropAction.drop)
        {
            assert(event.position < Point(50, 50));
            // at this point the above predicate should hold true

            auto text = event.getData!string;
            writefln("Received: %s", text);
        }
        -----

        $(B Note:) You may $(B not) access this property during a
        $(D DropAction.leave) action.
    */
    @property bool acceptDrop()
    {
        checkValidAction();
        return _acceptDrop;
    }

    /// ditto
    @property void acceptDrop(bool accept)
    {
        checkValidAction();
        _acceptDrop = accept;
    }

    /**
        Check whether the drop data contains data of type $(D DataType).

        $(B Note:) You may $(B not) access this property during a
        $(D DropAction.leave) action.
    */
    @property bool hasData(DataType)()
    {
        checkValidAction();
        return _dropData.hasData!DataType();
    }

    /**
        Check whether the drag & drop data is movable.
        Movable implies the data is copyable, moving the data
        has the semantic meaning defined by the source of the
        drag & drop operation.

        Typically, when moving data the source will copy the data
        and then delete the source of the data. This is typically
        equivalent to a Cut & Paste operation in a text editor.

        $(B Note:) You may $(B not) access this property during a
        $(D DropAction.leave) action.
    */
    @property bool canMoveData()
    {
        checkValidAction();
        return (_dropEffect & DropEffect.move) == DropEffect.move;
    }

    /**
        Check whether the drag & drop data is copyable.

        $(B Note:) You may $(B not) access this property during a
        $(D DropAction.leave) action.
    */
    @property bool canCopyData()
    {
        checkValidAction();
        return (_dropEffect & DropEffect.copy) == DropEffect.copy;
    }

    /**
        Move the data of type $(D DataType) from source and return it.

        $(B Note:) You may $(B not) access this function during a
        $(D DropAction.leave) action.
    */
    DataType moveData(DataType)()
    {
        checkValidAction();
        enforce(canMoveData, "Source does not allow data to be moved.");

        scope(success)
        {
            _dropEffect = DropEffect.move;
            _acceptDrop = true;
        }

        return _dropData.getData!DataType();
    }

    /**
        Copy the data of type $(D DataType) from source and return it.

        $(B Note:) You may $(B not) access this function during a
        $(D DropAction.leave) action.
    */
    DataType copyData(DataType)()
    {
        checkValidAction();
        enforce(canCopyData, "Source does not allow data to be copied.");

        scope(success)
        {
            _dropEffect = DropEffect.copy;
            _acceptDrop = true;
        }

        return _dropData.getData!DataType();
    }

    /**
        Get the position of the mouse pointer relative to the target widget.

        $(B Note:) You may $(B not) access this property during a
        $(D DropAction.leave) action.
    */
    @property Point position()
    {
        checkValidAction();
        return _position;
    }

    /**
        A bit mask of all key modifiers that were
        held when the drag & drop event was generated.

        Examples:
        -----
        // test if control was held
        if (keyMod & KeyMod.control) { }

        // test if both control and alt were held at the same time
        if (keyMod & (KeyMod.control | KeyMod.alt)) { }
        -----

        $(B Note:) The modifiers supported during a drag and drop
        operation are:
        - control, alt, shift, mouse_left, mouse_middle, mouse_right.

        $(B Note:) You may $(B not) access this property during a
        $(D DropAction.leave) action.
    */
    @property KeyMod keyMod()
    {
        checkValidAction();
        return _keyMod;
    }

package:
    DropEffect _dropEffect;
    bool _acceptDrop;

private:
    private void checkValidAction(string file = __FILE__, size_t line = __LINE__, string func = __FUNCTION__)
    {
        enforce(action != DropAction.leave,
            format("Cannot access the '%s' property during a '%s' action.",
                func.unqualed(), action), file, line);
    }

private:
    Point _position;
    KeyMod _keyMod;
    DropData _dropData;
}

/** Widget-specific events. */

/// Button widget event.
enum ButtonAction
{
    /// sentinel
    none,

    /// sentinel
    invalid,

    /// A button was pushed.
    push,
}

///
class ButtonEvent : Event
{
    this(Widget widget, ButtonAction action, TimeMsec timeMsec)
    {
        super(widget, EventType.button, timeMsec);
        this.action = action;
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /** Get the button this event is targetted at. */
    @property Button button()
    {
        return cast(Button)widget;
    }

    /** The action that triggered this button event. */
    const(ButtonAction) action;
}

///
enum CheckButtonAction
{
    /// sentinel
    none,

    /// A checkbutton was toggled on.
    toggleOn,

    /// A checkbutton was toggled off.
    toggleOff,
}

/// Check button widget event.
class CheckButtonEvent : Event
{
    this(Widget widget, CheckButtonAction action, TimeMsec timeMsec)
    {
        super(widget, EventType.check_button, timeMsec);
        this.action = action;
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /** Get the checkbutton this event is targetted at. */
    @property CheckButton checkButton()
    {
        return cast(CheckButton)widget;
    }

    /// ditto
    public alias button = checkButton;

    /** The action that triggered this checkbutton event. */
    const(CheckButtonAction) action;
}

/// Menu widget event.
enum MenuAction
{
    /// sentinel
    none,

    /// A regular menu item was selected.
    command,

    /// A check menu item was toggled on or off.
    toggle,

    /// A radio menu item was selected in a radio menu group.
    radio,
}

/// Menu widget event.
class MenuEvent : Event
{
    this(Widget widget, MenuAction action, CommonMenu rootMenu, TimeMsec timeMsec)
    {
        super(widget, EventType.menu, timeMsec);
        this.action = action;
        this.rootMenu = rootMenu;
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /**
        If $(D action) equals $(D MenuAction.command), returns the
        $(D MenuItem) widget that was selected.
        Otherwise, returns null.
    */
    @property MenuItem menuItem()
    {
        if (action != MenuAction.command)
            return null;

        return cast(MenuItem)widget;
    }

    /**
        If $(D action) equals $(D MenuAction.toggle), returns the
        $(D ToggleMenuItem) widget that was selected.
        Otherwise, returns null.
    */
    @property ToggleMenuItem toggleMenuItem()
    {
        if (action != MenuAction.toggle)
            return null;

        return cast(ToggleMenuItem)widget;
    }

    /**
        If $(D action) equals $(D MenuAction.radio), returns the
        $(D RadioGroupMenu) associated with the radio menu button
        that was selected. Otherwise, returns null.

        To check which radio menu button was
        selected, inspect the radio group's $(D value) property.
    */
    @property RadioGroupMenu radioGroupMenu()
    {
        if (action != MenuAction.radio)
            return null;

        return cast(RadioGroupMenu)widget;
    }

    /** The root menu where the signal was emitted from. */
    CommonMenu rootMenu;

    /** The action that triggered this menu event. */
    const(MenuAction) action;
}

/// Combobox widget event.
class ComboboxEvent : Event
{
    this(Widget widget, TimeMsec timeMsec)
    {
        super(widget, EventType.combobox, timeMsec);
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /**
        Return the target Combobox widget for this event.
    */
    @property Combobox combobox()
    {
        return cast(Combobox)widget;
    }
}

/// Entry widget event.
class EntryEvent : Event
{
    this(Widget widget, TimeMsec timeMsec)
    {
        super(widget, EventType.entry, timeMsec);
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /**
        Return the target Entry widget for this entry event.
    */
    @property Entry entry()
    {
        return cast(Entry)widget;
    }
}

///
enum ValidateAction
{
    /// Sentinel
    none,

    /// Requested when new text is being inputted.
    insert,

    /// Requested when (part of) the target entry is being deleted.
    remove,

    /// Requested when the widget holding the target text re-validates
    /// the text, e.g. during widget focus changes.
    revalidate,
}

/// Validate event.
class ValidateEvent : Event
{
    this(Widget widget, ValidateAction action, sizediff_t charIndex, string newValue, string oldValue, string editValue, ValidateMode validateMode, ValidateMode validateCondition, TimeMsec timeMsec)
    {
        super(widget, EventType.validate, timeMsec);
        this.action = action;
        this.charIndex = charIndex;
        this.newValue = newValue;
        this.oldValue = oldValue;
        this.editValue = editValue;
        this.validateMode = validateMode;
        this.validateCondition = validateCondition;
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /**
        Return the target Entry widget for this validate event.
    */
    @property Entry entry()
    {
        return cast(Entry)widget;
    }

    /**
        Set this property to mark that the validator handler has
        either validated the new entry or that the validation failed.

        If this property is never called in any of the chain of
        event handlers it is assumed the validation failed.

        $(B Note:) Calling this also sets the $(D handled) field to
        true, which will stop further propagation of the event.
    */
    @property void validated(bool isValidated)
    {
        this.handled = true;
        _validated = isValidated;
    }

    /** Get the current state of validation. */
    @property bool validated()
    {
        return _validated;
    }

    /** The action that triggered this validate event. */
    const(ValidateAction) action;

    /** The index of the character in the string to be inserted/deleted, if any, otherwise -1. */
    const(sizediff_t) charIndex;

    /**
        In prevalidation, the new value to best of the entry if the edit is accepted.
        In revalidation, the current value of the entry.
    */
    const(string) newValue;

    /** The current value of entry prior to editing. */
    const(string) oldValue;

    /** The text string being inserted/deleted, if any, otherwise empty. */
    const(string) editValue;

    /** The validation mode of the target widget. */
    const(ValidateMode) validateMode;

    /**
        The validation condition that created the event.

        For example, if the validateMode is set to $(B ValidateMode.all),
        validationCondition will contain the condition that triggered the
        validation (e.g. $(B ValidateMode.key)).
    */
    const(ValidateMode) validateCondition;

package:
    bool _validated;
}

///
enum ListboxAction
{
    /// Sentinel.
    none,

    /// The selection in the listbox was changed.
    select,

    /// The items in the listbox have changed.
    edit,
}

/// Listbox widget event.
class ListboxEvent : Event
{
    this(Widget widget, ListboxAction action, TimeMsec timeMsec)
    {
        super(widget, EventType.listbox, timeMsec);
        this.action = action;
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /** The action that triggered this listbox event. */
    const(ListboxAction) action;

    /** Return the target Listbox widget for this event. */
    @property Listbox listbox()
    {
        return cast(Listbox)widget;
    }
}

/// RadioButton event.
class RadioButtonEvent : Event
{
    this(Widget widget, TimeMsec timeMsec)
    {
        super(widget, EventType.radio_button, timeMsec);
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /** Return the target RadioGroup widget for this event. */
    @property RadioGroup radioGroup()
    {
        return cast(RadioGroup)widget;
    }
}

///
class SliderEvent : Event
{
    this(Widget widget, TimeMsec timeMsec)
    {
        super(widget, EventType.slider, timeMsec);
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /** Return the target Slider widget for this event. */
    @property Slider slider()
    {
        return cast(Slider)widget;
    }
}

///
class ScalarSpinboxEvent : Event
{
    this(Widget widget, TimeMsec timeMsec)
    {
        super(widget, EventType.scalar_spinbox, timeMsec);
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /** Return the target ScalarSpinbox widget for this event. */
    @property ScalarSpinbox scalarSpinbox()
    {
        return cast(ScalarSpinbox)widget;
    }
}

///
class ListSpinboxEvent : Event
{
    this(Widget widget, TimeMsec timeMsec)
    {
        super(widget, EventType.list_spinbox, timeMsec);
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, this.tupleof);
    }

    /** Return the target ListSpinbox widget for this event. */
    @property ListSpinbox listSpinbox()
    {
        return cast(ListSpinbox)widget;
    }
}
