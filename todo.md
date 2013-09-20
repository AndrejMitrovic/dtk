Now working on:
Menus.

Todo:

- Cairo support should be handled somehow.

- Slider should become templated, and we should allow a limited range slider as well, e.g.:
new Slider!int(0, 10, 2);  // from 0 to 10, stepping 2
new Slider!int([0, 1, 2, 3, 4]);  // only allow these items.

- Instead of using fake widgets, we should use a frame type as the Tk type.

- Widget parameter should be called parent, not master.

- Try to wrap many more virtual events of each widget type.

- Replace this:
override void toString(scope void delegate(const(char)[]) sink)

With a template that does this:
callFunc((cast(DynamicType)object).tupleof);

- Rewrite image test after all other widgets are wrapped, since events have to be handled first.

- Major todo: catch exceptions: http://www.gamedev.net/page/resources/_/technical/general-programming/d-exceptions-and-c-callbacks-r3323

- Add note about using (scope BaseClass event) for event handlers.

- Implement assertEqual to utils or somewhere.

- toString for widget events should print more data rather than just use .tupleof. It should take @property
functions into account.

- Remove the private _varName variables where we don't need to keep a reference to them. They only waste memory.

- All widget event types should have a property which returns the dynamic type of the target widget.

- Hide format and other code from dtk.utils from user.

- Work on menu's again later after fixing up events for other widgets.
Menus and their items can also be configured in many ways, we have to export this.

- Make library const-correct.

- All labels need to be called with _tclEscape

- Add indeterminate mode to checkbutton.

- Have to add position/size properties to each widget, but some have a specific setting for these fields.

- Replace these sort of calls with assertOp in the test-suite:
    assert(e.action == action, text(e.action, " != ", action));

- Add behavior tests for event handling of keyboard and mouse, e.g. when
a entry widget has a keyboard event, when is it a request event v.s. when
is it a post-action event.

- Add a status bar option to a Window.

- Implement a Maya-style spinbox, which increases-decreases when you click and hold the up/down buttons.

- Scale widget doesn't respond to up/down properly when it has an opposite orientation.
Bugfix patch:
https://core.tcl.tk/tk/ci/57f9af7736?sbs=1
    - Check if tcl functions can be overwritten, it would make the above easily fixable.

    - Otherwise check if we can copy an entire style (there's a copy command used in ttk button.tcl
    where they copy the behavior of buttons and checkbuttons):
    ttk::copyBindings TButton TCheckbutton

        - This would also allow us to set custom repeat delays and to provide custom widget features.

        - We could use string imports to import a tcl script.

- We could provide a set of helper functions with which to build custom widgets, e.g. see
functions in ttk's utils.tcl. We should also provide the user to source their own
tcl scripts via string imports or dynamically.

- We can override the ttk::button behavior and add button release events.

- Standard Widget options to port:
    - class
    - cursor
    - style
    - takefocus (can take a command)

- The geometry module needs to have more methods and operators, e.g. +, +=, etc.

- Use the 'when' option for sendEvent/postEvent:
    -when when
        When determines when the event will be processed; it must have one of the following values:
        now
            Process the event immediately, before the command returns. This also happens if the -when option is omitted.
        tail
            Place the event on Tcl's event queue behind any events already queued for this application.
        head
            Place the event at the front of Tcl's event queue, so that it will be handled before any other events already queued.
        mark
            Place the event at the front of Tcl's event queue but behind any other events already queued with -when mark. This option is useful when generating a series of events that should be processed in order but at the front of the queue.

- Add a .dup property for events.

- When can use virtual events, added with 'event add' to hook directly to key sequences, we should provide
an API for this. E.g.:

    auto seq = KeySeq(KeyMod.control | KeyMod.alt, KeySym.a);
    widget.onKeySequence[seq] = (scope KeySequence event) { ... }

    Perhaps we could make KeySeq a subclass of an Event, so a user can dynamically cast an event
    to a key sequence event.

    - Although maybe a better idea is to simply make this a helper function which does:

    auto handler = makeKeySeqHandler(KeySeq(KeyMod.control | KeyMod.alt, KeySym.a),
                                    (scope KeySequence event) { ... } ));
    widget.onEvent.connect(handler);

- Add test-suite for event handlers.

- Find all valid substitutions for each event type.

- Remove fake widgets if we can.

- Put place, pack, and grid commands into a separate layout file.

- The wm attributes command has OS-specific commands. We could ideally implement
this via opDispatch, to ensure that calling these functions in D doesn't break
cross-compilation. Instead of breaking compilation, we could issue a pragma(msg)
for the unsupported OS calls, and tell the user to use version(Windows) statements.

- We could create our own animation framework, by creating tcl scripts which call
the 'after' tcl command.
Animation examples: http://wiki.tcl.tk/14082
http://wiki.tcl.tk/_/search?S=%20animation

- Could implement a setOptions, for multiple options. We can call ".widget configure -width 100 -height 100" instead of using two separate configure calls.

- Consider using command instead of variable tracing for some widgets, since we might
want to separate events into those triggered by the OS (e.g. user interaction),
and those by internal user code.

- Turn some helper package methods into public methods, since they can be useful for people
who write extensions in Tcl and want to provide a D wrapper for them. We could also move these
functions into a helper module or helper package.

- We might have to delay-initialize all widgets to avoid having to pass a parent widget in a widget constructor.
However this means we have to check if a widget is initialized before attempting to call one of its methods,
so maybe it's better if we avoid delay-initializing widgets except those which would be awkward to use otherwise,
for example menus and menu items should not take parents since they can be inserted at arbitrary places.
Todo: See which other Tk widget types have an insert method, which would require delay initialization.

- Add mnemonic support to menu items via "&", e.g. "&File". But make sure we allow escaping via "&&File", which would produce "&File" in the menu.

- Check all 'todo' sections in the codebase.

- Check all filed bugs for Tk.

- Fix up signals so removal while iterating is handled properly:
http://d.puremagic.com/issues/show_bug.cgi?id=10821
Also make sure to document these issues.

- Add typed equivalents to most widgets which can have options set. E.g. we could have:

auto button = new TypedCheckButton!float("label", 0.0, 1.0);
auto button = new TypedCheckButton!char("label", 'a', 'z');

- The .#widget issue has been resolved, see the reply on SO:
http://stackoverflow.com/questions/18290171/strange-result-when-calling-winfo-children-on-implicitly-generated-toplevel-wi

- Instead of returning .init for canceled operations, return a struct with an ok/cancel value
and the field with the result.

- Implement an exception hierarchy, which will be kept in a single module.

- Subclasses should try and catch tcl-eval exceptions, and maybe wrap them, e.g. Image class should throw
  an Image Exception.

- Expose all widget options, e.g. we missed some like bbox.
See all the options for each widget type in the Tk command manual.

- Implement toString for widget classes. Could use the text option which most widgets have.

- Find a way to get the win32 cursor blinking time, and then use insertOffTime in the text widget
to modify the blinking. Try to see if other widgets support this option, otherwise ask in the
Tcl newsgroups whether these widgets should support this option, or whether they should follow
system-default settings. Finally, we could try finding how insertOffTime is set in Tcl and apply
this to other input widgets and distribute these new widgets.

- The _isDestroyed bool we added should likely be checked in most function calls, but this might be
expensive. Maybe we should use an invariant.

- Replace all boolean parameters and fields with enums, except where the usage is clear.

- Once the toolkit is in place we should port the widget demo from Tcl:
C:\Program Files (x86)\Tcl\demos\Tk8.6

- ttk::menubutton is not ported yet. See also which other ttk widgets we have to port that are not listed
on tkdocs.com.

- Text, canvas, and tree widgets (and maybe more) have a tagging ability, which enables us to e.g.
set the same image to multiple objects, and to generate events.

- Port Cursors.

- Info about what the event loop does, and what idle commands do:
http://wiki.tcl.tk/1527

- Can generate mouse moves, by setting -warp to true in the event generate command.

Tk info (move this to an info.md file):

- Key codes are in keysymdef.h

- Percent substitution is made in ExpandPercents in tk/generic/tkBind.c

Docs todo:
- You can only send key events to the focused window. If we add support for manually creating events, we should
  make sure we focus a window, or only allow sending the keyboard event to the focused window.

- Make a note about having to use either -L/SUBSYSTEM:WINDOWS:5.01 (32bit) or -L/SUBSYSTEM:WINDOWS:5.02 (64bit) when compiling DTK apps on windows, or alternatively using WinMain. Otherwise some weird resizing behavior happens with windows instantiated by Tk. See also:
https://github.com/aldacron/Derelict3/issues/143

- Document how multi-click events are delivered:
    event button: button1 action press
    event button: button1 action release
    event button: button1 action double_click
    event button: button1 action release
    event button: button1 action triple_click
    event button: button1 action release
    event button: button1 action quadruple_click
    event button: button1 action release
