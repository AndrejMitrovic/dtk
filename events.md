Documenting what our event system should look like before it's implemented:

## Event propagation

We implement event sinking (tunneling in WPF terminology), and bubbling.

E.g.:

Toplevel .toplevel
    Frame .frame
        Button .button

When .button is pressed, regardless of Tk's internal event system, the D system will be:

- Begin sinking or tunneling:

1. Invoke .toplevel.onEvent.emit(widget, event). onEvent is defined as:

    Signal!(EventHandled, scope Event) onEvent;

    Where the return type is EventHandled
        - todo: make Signal take the return type as the first option.

    The 'widget' parameter will be .button, and Event is either a class or union struct,
    see the Event definition section.

2. If .toplevel.onEvent returns EventHandled.yes, propagation (tunneling or sinking) stops.
   Otherwise, continue with #3.

3. Invoke .frame.onEvent.emit(widget, event)

## Event type

Two options:

1) Class type:
    Pros:
        - Reference semantics make it easy to use and reason about.
        - It has no performance impact when passed to functions, reference semantics.
        - User can derive and create new event types.
        - Polymorphic cast is simple and familiar to people.
    Cons:
        - Performance impact: It can cause too many small GC allocations.
            -> Workaround #1: Use emplace to allocate the class either on the stack or
               in some static array.
            -> Workaround #2: Use some __gshared events, e.g. pointer events. Harmonia
               uses this trick, since a Pointer event can normally happen only once
               at a time, e.g.:

            static EventKey _keyEvent;
            static EventPointer _pointerEvent;
            static EventPointer _enterLeaveEvent;
            static EventWidget  _widgetEvent;
            static EventCommand _commandEvent;
            static EventControl _controlEvent;

            - Note: Provide docs and a dup() method if the user wants to keep the
            event around. Maybe add:

            class Event
            {
                bool _isMemorySafe = true;

                invariant()
                {
                    assert(_isMemorySafe);
                }

                abstract Event dup()  // overridable
                {
                    auto result = new Event(this.tupleof);
                }
            }

            And in our event dispatcher we use:

            Window.staticPointer._isMemorySafe = true;
            Window.staticPointer.initialize(...);  // init new data
            propagateEvent(Window.staticPointer);
            Window.staticPointer._isMemorySafe = false;

            Then if the user code continues to call into this event
            because they stored a reference, they will trigger the
            invariant.

            However we should use a static array of classes, to allow
            the user code to trigger the _isMemorySafe check before
            the data is overwritten underneath it.

            -> Workaround #3: Use scoped!() and make event handlers take
            a scope Event type. Once scope is properly implemented it will
            be safe to use, until then a documentation note should be made.

2) Polymorphic struct type:
    Pros:
        - Fast stack allocation, and fast static array allocation.

    Cons:
        - Performance impact when copied around, based on the uniform event byte size.
            -> Workaround: Pass by ref, but it's unsafe if an address of it is taken.
                -> Workaround: `scope ref`, currently disallowed by the parser (Issue 8121).
                   But even with a fix `scope` currently does nothing.
        - Value semantics are potentially error-prone (e.g. in foreach loops, passing to functions).
        - User cannot derive, introducing new event types is not possible.
        - Specialized `get` method is used for polymorhism, something people might not get used to.

- Note: we should maybe name our event types with a leading Event, which could make it easier to
autocomplete:
