package require Tk

wm title . "Radiobuttons"

ttk::radiobutton .home -text "Home" -variable phone -value home
ttk::radiobutton .office -text "Office" -variable phone -value office
ttk::radiobutton .cell -text "Mobile" -variable phone -value cell

# Stick to north, south, east, west, and set to grid [0, 0]
#~ grid .home -column 0 -row 0 -sticky nsew
pack .home
pack .office
pack .cell
