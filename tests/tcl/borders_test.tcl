package require Tk

tkwait visibility .

ttk::frame .myframe -padding "3 3 12 12" -width 100 -height 100
.myframe configure -borderwidth 10 -relief sunken

pack .myframe

#~ wm geometry . 100x100+10+10

#~ update idletasks
#~ puts [wm geometry .]

. configure -borderwidth 5 -relief ridge
