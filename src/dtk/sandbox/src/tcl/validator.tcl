package require Tk

set ::dtk_var10424192_0 ""

proc validate_func {args} {
    puts "$args"

    #~ .entry delete 0 end
    #~ .entry insert 0 "blabla"

    return false
}

ttk::entry .entry -textvariable ::dtk_var10424192_0

trace add variable ::dtk_var10424192_0 write { validate_func entry .tk__toplevel104241920.ttk__entry104241921 $::dtk_var10424192_0 }
#~ trace add variable ::dtk_var10424192_0 write { validate_func ::dtk_var10424192_0 $::dtk_var10424192_0 }

.entry insert 0 "foo"

set ::myvar true



# %d => Type of action - 1 for insert prevalidation, 0 for delete prevalidation, or -1 for revalidation.
# %i => Index of character string to be inserted/deleted
# %P => In prevalidation, the new value of the entry if the edit is accepted. In revalidation, the current value of the entry.
# %s => The current value of entry prior to editing.
# %S => The text string being inserted/deleted, if any.
# %v => The current value of the -validate option
# %V => The validation condition that triggered the callback (key, focusin, focusout, or forced).
# %W => Widget path

#~ .entry configure -validate "key"
#~ .entry configure -validatecommand "validate_func TkValidate %d %i %P %s %S %v %V %W"

#~ ttk::entry .name -textvariable username
pack .entry
