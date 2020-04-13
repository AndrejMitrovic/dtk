package require Tk

wm title . "Grid"

ttk::frame .c
ttk::frame .c.f -borderwidth 5 -relief sunken -width 200 -height 100
ttk::label .c.namelbl -text Name
ttk::entry .c.name
ttk::checkbutton .c.one -text One -variable one -onvalue 1; set one 1
ttk::checkbutton .c.two -text Two -variable two -onvalue 1; set two 0
ttk::checkbutton .c.three -text Three -variable three -onvalue 1; set three 1
ttk::button .c.ok -text Okay
ttk::button .c.cancel -text Cancel

grid .c -column 0 -row 0
grid .c.f -column 0 -row 0 -columnspan 3 -rowspan 2
grid .c.namelbl -column 3 -row 0 -columnspan 2
grid .c.name -column 3 -row 1 -columnspan 2
grid .c.one -column 0 -row 3
grid .c.two -column 1 -row 3
grid .c.three -column 2 -row 3
grid .c.ok -column 3 -row 3
grid .c.cancel -column 4 -row 3
