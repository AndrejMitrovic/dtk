- Standard Widget options to port:
    - class
    - cursor
    - style
    - takefocus (can take a command)

Todo now:

- When we set up commands for dtk, we should use action enums instead of Tk enums, prefer
ButtonAction.push over TkEvent.tkButtonPush, since the former is what we store anyway.

- Add test-suite for event handlers.

- We could use a template getter for the timestamp, which returns a Duration. This avoids
  huge build times for importing std.datetime until the timestamp is used.

- Use toString with a sink, to avoid allocating memory.

- Use better typeid extraction (see what it consists of, so we can get rid of the full path name)

- Key codes are in keysymdef.h

- Percent substitution is made in ExpandPercents in tk/generic/tkBind.c

- Find all valid substitutions for each event types.

- Remove as many fake widgets as possible, and simplify super ctor in Widget.
- Call bindtags for all real widgets

- We can use 'generate window event' to simulate mouse clicks. We should use
this for the unittests.

- Could use 'bind Button <event>' to bind all tk class types to static
C functions in the D classes.

- Put place, pack, and grid commands into a separate layout file.

- The wm attributes command has OS-specific commands. We could ideally implement
this via opDispatch, to ensure that calling these functions in D doesn't break
cross-compilation. Instead of breaking compilation, we could issue a pragma(msg)
for the unsupported OS calls, and tell the user to use version(Windows) statements.

- Event propagation, should events propagate upwards and downwards? Harmonia has sinking and bubbling.

- Include the new signals implementation, and make buttons emit signals instead of
invoke a specific function or delegate. Update: We should avoid using signals
for now, due to the complicated nature of adding/removing signal handlers
while they're being called. Instead we should provide simple callbacks such as:
button1.onClick(&handler);
This is similar to GTKD, we should check it out there. Then, if the user wants
he can use his own signals in a derived class or a supertype.

- We could create our own animation framework, by creating tcl scripts which call
the 'after' tcl command.
Animation examples: http://wiki.tcl.tk/14082
http://wiki.tcl.tk/_/search?S=%20animation

- Use custom binding substitution or formatting arguments for each signal type:
http://www.tcl.tk/man/tcl8.6/TkCmd/bind.htm#M24

- Could also use custom event types instead of a generic Event class, that way
we don't have to store everything into one giant event structure. This will
require some metaprogramming at the callback site.

This will enable us to use a single onMouseEvent instead of onMouseEnter+onMouseLeave

- Use SendMessage to simulate keyboard and mouse input when unittesting.
Note: We'll have to use PostThreadMessage instead since the main thread will
be blocked in the event loop.

- Could implement a setOptions, for multiple options. We can call ".widget configure -width 100 -height 100" instead of using two separate configure calls.

- Consider using command instead of variable tracing for some widgets, since we might
want to separate events into those triggered by the OS (e.g. user interaction),
and those by internal user code.

- Turn package methods into public methods, since they can be useful for people who write
extensions in Tcl and want to provide a D wrapper for them. As a last resort we could
move these functions into a helper module or helper package.

- We might have to delay-initialize all widgets to avoid having to pass a parent widget in a widget constructor.
However this means we have to check if a widget is initialized before attempting to call one of its methods,
so maybe it's better if we avoid delay-initializing widgets except those which would be awkward to use otherwise,
for example menus and menu items should not take parents since they can be inserted at arbitrary places.
Todo: See which other Tk widget types have an insert method, which would require delay initialization.

- Add mnemonic support to menu items via "&", e.g. "&File". But make sure we allow escaping via "&&File", which would produce "&File" in the menu.

- Make sure we're quoting all strings right. Add checks to each constructor or function taking a string and
ensure strings with spaces work.

- Check all 'todo' sections in the codebase.

- Check all filed bugs.

- Fix up signals so removal while iterating is handled properly:
http://d.puremagic.com/issues/show_bug.cgi?id=10821
Also make sure to document these issues.

- Remove methods from Widget class that should be in derived classes, this should avoid confusion
on their meaning.

- Add Typed equivalents to most widgets which can have options set. E.g. we could have:

auto button = new TypedCheckButton!float("label", 0.0, 1.0);
auto button = new TypedCheckButton!char("label", 'a', 'z');

- Make a big note about having to use either -L/SUBSYSTEM:WINDOWS:5.01 (32bit) or -L/SUBSYSTEM:WINDOWS:5.02 (64bit) when compiling DTK apps on windows, or alternatively using WinMain. Otherwise some weird resizing behavior happens with windows instantiated by Tk. See also:
https://github.com/aldacron/Derelict3/issues/143

- The .#widget issue has been resolved, see the reply on SO:
http://stackoverflow.com/questions/18290171/strange-result-when-calling-winfo-children-on-implicitly-generated-toplevel-wi

- We'll need to call _escapePath for any Tk API which takes paths (or even plain strings), since backslashes are problematic due to required escaping.

- Instead of returning .init for canceled operations, return a struct with an ok/cancel value
and the field with the result.

- Some widgets have an identity function which returns the widget under position X and Y.
We could try and generalize this by adding an event callback for onMouseMove or
onMousePress, which would return the normal X/Y coordinates but also the widget under the
mouse cursor.

- Error checking: must check all eval calls and throw D exceptions on any errors received.
There should be an error state stored in the interpreter struct. See the eval docs.

- Expose all widget options, e.g. we missed some like bbox.
See all the options for each widget type in the Tk command manual.

- Implement toString for widget classes. Could use text option which most widgets have.

- Instead of using DtkOptions and a super call, we should try to always call property functions
in the ctor. This will avoid code duplication and will be more clean.

- Could make evalFmt in widgets always prepend _name, since that's how we always use it anyway.

- Find a way to get the win32 cursor blinking time, and then use insertOffTime in the text widget
to modify the blinking. Try to see if other widgets support this option, otherwise ask in the
Tcl newsgroups whether these widgets should support this option, or whether they should follow
system-default settings. Finally, we could try finding how insertOffTime is set in Tcl and apply
this to other input widgets and distribute these new widgets.

- The _isDestroyed bool we added should likely be checked in most function calls, but this might be
expensive. Perhaps we should simply use an invariant for this.

- Replace all boolean parameters and fields with enums.

- Read in detail about Tcl's string escaping and quoting rules because they seem complicated.
Apparently we should only escape inner curly braces: http://stackoverflow.com/a/5302213/279684

- See if we can replace fake widgets from inheriting the Widget class and instead use App.evalFmt directly,
but only if _name isn't used.

- Implement exceptions for all eval calls. E.g. image loading should throw an ImageLoad exception, etc.

- Once the toolkit is in place we should port the widget demo from Tcl:
C:\Program Files (x86)\Tcl\demos\Tk8.6

- ttk::menubutton is not ported yet. See also which other ttk widgets we have to port that are not listed
on tkdocs.com.

- Text, canvas, and tree widgets (and maybe more) have a tagging ability, which enables to e.g.
set the same image to multiple objects, and to generate events.

- Port Cursors.

- Info about what the event loop does, and what idle commands do:
http://wiki.tcl.tk/1527

- Can generate mouse moves, see "moving the mouse pointer" at the bottom of this page:
http://www.tcl.tk/man/tcl8.6/TkCmd/event.htm

- Disability features:
PS: for the double-click timings: most people won't ever
  touch them, but people with certain disabilities might
  very strongly depend on being able to enlarge this time.
