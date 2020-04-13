package require Tk

ttk::entry .entry -textvariable textvar -validate "all" -validatecommand {
    puts "New Value: %P, textvar: $textvar"
    return true
}

# Side-steps validator, it doesn't get called.
set textvar "bar"

# But this does
.entry insert 0 "insert "

# Echo's: "insert bar"
puts $textvar

pack .entry
