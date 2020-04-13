package require Tk

wm title . "Frames"

image create photo myimg -file "dmc.png"

ttk::label .label
.label configure -image myimg

pack .label
