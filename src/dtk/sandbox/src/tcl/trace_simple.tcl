package require Tk

wm title . "Checkbuttons"

ttk::checkbutton .check -text "Use Metric" -command { d_callback ::dtk_myvar $::dtk_myvar } -variable ::dtk_myvar -onvalue metric -offvalue imperial

pack .check
.check instate alternate

# We instantiate one of these
proc d_callback {name value} {
    puts "$name was updated to be $value"
}

#~ # We instantiate one of these
#~ proc tracer {varname args} {
    #~ upvar #0 $varname var
    #~ d_callback $varname $var
#~ }

#~ trace add variable ::dtk_myvar write "tracer ::dtk_myvar"
