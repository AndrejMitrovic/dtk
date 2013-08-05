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

Put place, pack, and grid commands into a separate layout file.

The wm attributes command has OS-specific commands. We could ideally implement
this via opDispatch, to ensure that calling these functions in D doesn't break
cross-compilation. Instead of breaking compilation, we could issue a pragma(msg)
for the unsupported OS calls, and tell the user to use version(Windows) statements.

