Todo:

- tk style map states:
static const char *const stateNames[] =
{
    "active",		/* Mouse cursor is over widget or element */
    "disabled",		/* Widget is disabled */
    "focus",		/* Widget has keyboard focus */
    "pressed",		/* Pressed or "armed" */
    "selected",		/* "on", "true", "current", etc. */
    "background",	/* Top-level window lost focus (Mac,Win "inactive") */
    "alternate",	/* Widget-specific alternate display style */
    "invalid",		/* Bad value */
    "readonly",		/* Editing/modification disabled */
    "hover",		/* Mouse cursor is over widget */
    "reserved1",	/* Reserved for future extension */
    "reserved2",	/* Reserved for future extension */
    "reserved3",	/* Reserved for future extension */
    "user3",		/* User-definable state */
    "user2",		/* User-definable state */
    "user1",		/* User-definable state */
    NULL
};

- scrollbars should be more configurable since the xview/yview command
is possible to implement, and -xscrollcommand/-yscrollcommand for widgets.

- sizegrip can't be constructed, but Window uses it,
but a sizegrip has configuration options we should check.
alternatively in the enableSizegrip function we should add
parameters for configuration
auto sizegrip = new Sizegrip(testWindow);
assert(sizegrip.style == GenericStyle.sizegrip);

- Port menuButton

- Maybe add a rootMenu call to menus.

- Add rootTree as well.

- Replace this:
override void toString(scope void delegate(const(char)[]) sink)

With a template that does this:
callFunc((cast(DynamicType)object).tupleof);

- Replace these sort of calls with assertOp in the test-suite:
    assert(e.action == action, text(e.action, " != ", action));
    Implement assertEqual to utils or somewhere.

- toString for widget events should print more data rather than just use .tupleof. It should take @property
functions into account.

- Work on menus again. Menus and their items can also be configured in many ways, we have to export this.

- Add a status bar option to a Window.

- We could provide a set of helper functions with which to build custom widgets, e.g. see
functions in ttk's utils.tcl. We should also provide the user to source their own
tcl scripts via string imports or dynamically.

- We can override the ttk::button behavior and add button release events.

- Port cursors

- The geometry module needs to have more methods and operators, e.g. +, +=, etc.

- Find all valid substitutions for each event type.

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

- Check all 'todo' sections in the codebase.

- Instead of returning .init for canceled operations, return a struct with an ok/cancel value
and the field with the result. (also see RGB struct).

- Check all filed bugs for Tk.

- Fix up signals so removal while iterating is handled properly:
http://d.puremagic.com/issues/show_bug.cgi?id=10821
Also make sure to document these issues.

- The .#widget issue has been resolved, see the reply on SO:
http://stackoverflow.com/questions/18290171/strange-result-when-calling-winfo-children-on-implicitly-generated-toplevel-wi

- Implement an exception hierarchy, which will be kept in a single module.

- Subclasses should try and catch tcl-eval exceptions, and maybe wrap them, e.g. Image class should throw
  an Image Exception.

- Expose all widget options, e.g. we missed some like bbox.
See all the options for each widget type in the Tk command manual.

- Implement toString for widget classes. Could use the text option which most widgets have.

- The _isDestroyed bool we added should likely be checked in most function calls, but this might be
expensive. Maybe we should use an invariant.

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

- Cairo support should be added somehow.

- Try to wrap more virtual events of each widget type.

- Add indeterminate mode to checkbutton.

Docs todo:
- You can only send key events to the focused window. If we add support for manually creating events, we should
  make sure we focus a window, or only allow sending the keyboard event to the focused window.


