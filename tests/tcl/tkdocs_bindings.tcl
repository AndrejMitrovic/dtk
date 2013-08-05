package require Tk
grid [ttk::label .l -text "Starting..."]
bind .l <Enter> {.l configure -text "Moved mouse inside"}
bind .l <Leave> {.l configure -text "Moved mouse outside"}
bind .l <1> {.l configure -text "Clicked left mouse button"}
bind .l <Double-1> {.l configure -text "Double clicked"}
bind .l <B3-Motion> {.l configure -text "right button drag to %x %y"}
