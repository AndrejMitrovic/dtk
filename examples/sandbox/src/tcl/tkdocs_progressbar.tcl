package require Tk

wm title . "Progressbar"

ttk::progressbar .bar -orient horizontal -length 200 -mode determinate

pack .bar
