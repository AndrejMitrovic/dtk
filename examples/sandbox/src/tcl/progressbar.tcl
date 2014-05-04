package require Tk

wm title . "Progressbar"

ttk::progressbar .pb -orient horizontal -length 200 -mode determinate
pack .pb

.pb configure -orient vertical
.pb configure -length 100
.pb configure -mode indeterminate
