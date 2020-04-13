package require Tk

ttk::entry .entry

.entry insert 0 "foo"

set ::myvar true

proc validate_func {args} {
    #~ puts "$args"

    #~ .entry delete 0 end
    #~ .entry insert 0 "blabla"

    return true
}

# %d => Type of action - 1 for insert prevalidation, 0 for delete prevalidation, or -1 for revalidation.
# %i => Index of character string to be inserted/deleted
# %P => In prevalidation, the new value of the entry if the edit is accepted. In revalidation, the current value of the entry.
# %s => The current value of entry prior to editing.
# %S => The text string being inserted/deleted, if any.
# %v => The current value of the -validate option
# %V => The validation condition that triggered the callback (key, focusin, focusout, or forced).
# %W => Widget path

.entry configure -validate "key"
.entry configure -validatecommand "validate_func TkValidate %d %i %P %s %S %v %V %W"

#~ ttk::entry .name -textvariable username
pack .entry
