Standard options to port:

    http://www.tcl.tk/man/tcl8.6/TkCmd/ttk_button.htm

    -class, undefined, undefined
    -compound, compound, Compound
    -cursor, cursor, Cursor
    -image, image, Image
    -state, state, State
    -style, style, Style
    -takefocus, takeFocus, TakeFocus
    -textvariable, textVariable, Variable

Remove 'text' from Widget class because it's confusing, e.g. some widgets
use text via 'configure -text', but other widgets don't -- the text widget
uses 'get' and 'set' methods, and 'configure -text' doesn't work for it
because it's not a ttk widget.

Also try removing other generic methods in the Widget class that might have
a different behavior in each subclass.

Put place, pack, and grid commands into a separate layout file.

The wm attributes command has OS-specific commands. We could ideally implement
this via opDispatch, to ensure that calling these functions in D doesn't break
cross-compilation. Instead of breaking compilation, we could issue a pragma(msg)
for the unsupported OS calls, and tell the user to use version(Windows) statements.

Include the new signals implementation, and make buttons emit signals instead of
invoke a specific function or delegate.

We could create our own animation framework, by creating tcl scripts which call
the 'after' tcl command.
Animation examples: http://wiki.tcl.tk/14082
http://wiki.tcl.tk/_/search?S=%20animation

Use custom binding substitution or formatting arguments for each signal type:
http://www.tcl.tk/man/tcl8.6/TkCmd/bind.htm#M24

Could also use custom event types instead of a generic Event class, that way
we don't have to store everything into one giant event structure. This will
require some metaprogramming at the callback site.

This will enable us to use a single onMouseEvent instead of onMouseEnter+onMouseLeave

Use SendMessage to simulate keyboard and mouse input when unittesting.
Note: We'll have to use PostThreadMessage instead since the main thread will
be blocked in the event loop.

Make a 'createTracedVar' which will simplify creating traced variables.

Could implement a setOptions, for multiple options. We can call ".widget configure -width 100 -height 100" instead of using two separate configure calls.

Consider using command instead of variable tracing for some widgets, since we might
want to separate events into those triggered by the OS (e.g. user interaction),
and those by internal user code.

Turn package methods into public methods, since they can be useful for people who write
extensions in Tcl and want to provide a D wrapper for them. As a last resort we could
move these functions into a helper module.

We might have to delay-initialize all widgets to avoid having to pass a parent widget in a widget constructor.
However this means we have to check if a widget is initialized before attempting to call one of its methods,
so maybe it's better if we avoid delay-initializing widgets except those which would be awkward to use otherwise,
for example menus and menu items should not take parents since they can be inserted at arbitrary places.
Todo: See which other Tk widget types have an insert method, which would require delay initialization.

Add mnemonic support to menu items via "&", e.g. "&File". But make sure we allow escaping via "&&File", which would produce "&File" in the menu.

Make sure we're quoting all strings right. Add checks to each constructor or function taking a string and
ensure strings with spaces work.

Check all 'todo' sections in the codebase.

Check all filed bugs.
