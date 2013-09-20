/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.event;

import std.array;
import std.traits;
import std.typecons;
import std.typetuple;

import dtk.geometry;
import dtk.keymap;
import dtk.signals;
import dtk.types;
import dtk.utils;

import dtk.widgets;

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

    /**
        An event emitted when a widget's size, position, or border width changes,
        and sometimes when it has changed position in the stacking order.
    */
    geometry,

    /**
        The mouse moved in or out of the area of a target widget.
    */
    hover,

    /**
        The widget was focused in or focused out.
    */
    focus,

    /** A widget is about to be destroyed. */
    destroy,

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

    /** Validation event when widget needs to validate some text. */
    validate,

    /** One or more items in a listbox widget were selected. */
    listbox,

    /** A radio button was selected in a radio group. */
    radio_button,
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

// todo: implement later
/+ // All standard event types are listed here, in the same order as EventType.
private alias EventClassMap = TypeTuple!(Event, Event, MouseEvent, KeyboardEvent);

// todo: add toEventType.
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
} +/

/** The root class of all event types. */
class Event
{
    /**
        This base class constructor is only called for user-derived events.
        It ensures the event type is initialized as a user event.

        It can optionally take a user event type tag.
    */
    this(Widget targetWidget, long userType = 0, TimeMsec timeMsec = 0)
    {
        this.userType = userType;
        this(targetWidget, EventType.user, timeMsec);
    }

    package this(Widget targetWidget, EventType type, TimeMsec timeMsec)
    {
        this.type = type;
        this.userType = 0;
        this.timeMsec = timeMsec;
        _targetWidget = targetWidget;
    }

    /**
        Get the timestamp when the event occured.
        The returned type is a $(D core.time.Duration) type.
        The time is relative to when the system started.
    */
    @property auto time()()
    {
        import core.time;
        return timeMsec.dur!"msecs";
    }

    /**
        The timestamp in milliseconds when the event occurred.
        The time is relative to when the system started.
        Use $(D time) to get a $(D Duration) type.
    */
    public const(TimeMsec) timeMsec;

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

    /** Return the current travel direction of this event. */
    @property EventTravel eventTravel()
    {
        return _eventTravel;
    }

    /** Output the string representation of this event. */
    void toString(scope void delegate(const(char)[]) sink) { }

    /**
        Derived classes should call $(D toStringImpl(sink, this.tupleof) )
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
        sink(format("%sm%ss", time.minutes, time.seconds));
        sink(")");
    }

package:

    /**
        The target widget for the event. Note that this isn't a const public field, since
        we want to allow modification to the widget, but disallow modification to the
        event object itself. Hence the property getter above.
    */
    Widget _targetWidget;

    /** The current travel direction of the event. */
    EventTravel _eventTravel;
}

/** A set of possible mouse actions. */
enum MouseAction
{
    /** One of the mouse buttons was pressed. */
    press = 0,

    /** One of the mouse buttons was released. */
    release = 1,

    /** Convenience - equal to $(D press). */
    click = press,

    /** One of the mouse buttons was clicked twice in rapid succession. */
    double_click = 2,

    /** One of the mouse buttons was clicked three times in rapid succession. */
    triple_click = 3,

    /** One of the mouse buttons was clicked four times in rapid succession. */
    quadruple_click = 4,

    /**
        The mouse wheel was moved. See the $(D wheel) field to determine
        the direction the mouse wheel was moved in.

        $(BLUE Note): When the wheel is pressed as a mouse button,
        the action will equal $(D press), not $(D wheel).
    */
    wheel = 5,

    /** The mouse was moved. */
    motion = 6,
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

private enum AnyModifier = 1 << 15;

/**
    A set of keyboard modifiers or active mouse buttons
    while another event was generated.

    Examples:
        - When the 'a' key is pressed, the shift keyboard modifier might be present.
        - When the left mouse button is pressed, the right mouse button might already
          be held down, in that case the right mouse button is the button modifier.
*/
enum KeyMod
{
    none = 0,

    /** Control key. */
    control = 1 << 2,

    /** Alt key. */
    alt = AnyModifier << 2,

    /** Convenience for OSX - equal to $(D alt). */
    option = alt,

    /** Shift key. */
    shift = 1 << 0,

    // todo: when caps lock is turned off, lock is set.
    // we can probably tell then if it's on or off.

    /** Capslock key. */
    capslock = 1 << 1,

    /**
        The meta key is present on special keyboards,
        such as the MIT keyboard.
        See: http://en.wikipedia.org/wiki/Meta_key
    */
    meta = AnyModifier << 1,

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
    extended = 1 << 15,

    /**
        The following are similarly named as the members of the
        $(D MouseButton) enum, but have a "mouse_" prefix.

        $(BLUE Note): The integral values of these members
        are not the same as the ones in the $(D MouseButton)
        enum, do not attempt to cast between the two.
    */

    /** The left mouse button. */
    mouse_button1 = 1 << 8,

    /** Convenience - equal to $(D mouse_button1). */
    mouse_left = mouse_button1,

    /** The middle mouse button. */
    mouse_button2 = 1 << 9,

    /** Convenience - equal to $(D mouse_button2). */
    mouse_middle = mouse_button2,

    /** The right mouse button. */
    mouse_button3 = 1 << 10,

    /** Convenience - equal to $(D mouse_button3). */
    mouse_right = mouse_button3,

    /** First additional button - hardware-dependent. */
    mouse_button4 = 1 << 11,

    /** Convenience - equal to $(D mouse_button4) */
    mouse_x1 = mouse_button4,

    /** Second additional button - hardware-dependent. */
    mouse_button5 = 1 << 12,

    /** Convenience - equal to $(D mouse_button5) */
    mouse_x2 = mouse_button5,
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

        See also: todo: add MSDN note about wheel delta,
        and a blog post.
    */
    const(int) wheel;

    /**
        A bit mask of all key modifiers that were
        held when the mouse event was generated.

        Examples:
        -----
        // test if control was held
        if (keyMod & KeyMod.control) { }

        // test if both control and alt were held at the same time
        if (keyMod & (KeyMod.control | KeyMod.alt)) { }
        -----
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
        A bit mask of all key modifiers that were
        held while keySym was pressed or released.

        Examples:
        -----
        // test if control was held
        if (keyMod & KeyMod.control) { }

        // test if both control and alt were held at the same time
        if (keyMod & (KeyMod.control | KeyMod.alt)) { }
        -----
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
        A bit mask of all key modifiers that were
        held when the mouse enter/leave hover event was generated.

        Examples:
        -----
        // test if control was held
        if (keyMod & KeyMod.control) { }

        // test if both control and alt were held at the same time
        if (keyMod & (KeyMod.control | KeyMod.alt)) { }
        -----
    */
    const(KeyMod) keyMod;
}

///
enum FocusAction
{
    /// The widget was focused in (the focus has entered the widget)
    enter,

    /// The widget was focused out (the focus has left the widget)
    leave,
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
        Whether the target widget was focused in or focused out.
    */
    const(FocusAction) action;
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

/** Widget-specific events. */

/// Button widget event.
enum ButtonAction
{
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
    invalid,

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
    this(Widget widget, string value, TimeMsec timeMsec)
    {
        super(widget, EventType.combobox, timeMsec);
        this.value = value;
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, value);
    }

    /**
        Return the target Combobox widget for this event.
    */
    @property Combobox combobox()
    {
        return cast(Combobox)widget;
    }

    /**
        The value of the combobox which was selected
        and which created this event.
    */
    const(string) value;
}

/// Entry widget event.
class EntryEvent : Event
{
    this(Widget widget, string value, TimeMsec timeMsec)
    {
        super(widget, EventType.entry, timeMsec);
        this.value = value;
    }

    ///
    override void toString(scope void delegate(const(char)[]) sink)
    {
        toStringImpl(sink, value);
    }

    /**
        Return the target Entry widget for this entry event.
    */
    @property Entry entry()
    {
        return cast(Entry)widget;
    }

    /**
        The value of the entry which was set
        and which created this event.
    */
    const(string) value;
}

///
enum ValidateAction
{
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

/** Old code below */

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
