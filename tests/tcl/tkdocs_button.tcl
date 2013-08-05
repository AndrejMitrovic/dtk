package require Tk

wm title . "Buttons"

ttk::button .button -text "Okay" -command "submitForm"

#~ ttk::frame .myframe -padding "3 3 12 12" -width 100 -height 100
#~ .myframe configure -borderwidth 2 -relief sunken

# Stick to north, south, east, west, and set to grid [0, 0]
grid .button -column 0 -row 0 -sticky nsew

.button configure -default active

.button state disabled      ; # set the disabled flag, disabling the button
.button state !disabled     ; # clear the disabled flag
.button instate disabled    ; # return 1 if the button is disabled, else 0
.button instate !disabled   ; # return 1 if the button is not disabled, else 0
#~ .button instate !disabled {mycmd } ;# execute 'mycmd' if the button is not disabled
