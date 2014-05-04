package require Tk

wm title . "Radiobuttons"

ttk::radiobutton .home -text "Home" -variable phone -value home
ttk::radiobutton .office -text "Office" -variable phone -value office
ttk::radiobutton .cell -text "Mobile" -variable phone -value cell

pack .home
pack .office
pack .cell
