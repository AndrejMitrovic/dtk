package require Tk

toplevel .win

menu .win.mymenu
. configure -menu .win.mymenu

puts [winfo children .win]
