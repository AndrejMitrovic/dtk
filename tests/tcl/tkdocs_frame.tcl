package require Tk

wm title . "Frames"

ttk::frame .myframe -padding "3 3 12 12" -width 100 -height 100
.myframe configure -borderwidth 2 -relief sunken

# Stick to north, south, east, west, and set to grid [0, 0]
grid .myframe -column 0 -row 0 -sticky nsew

# Follow the window size for item in grid [0, 0]
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1
