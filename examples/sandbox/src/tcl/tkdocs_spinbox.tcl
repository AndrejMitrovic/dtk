package require Tk

wm title . "Spinbox"

ttk::spinbox .spinbox -from 1.0 -to 100.0 -values [list a b c] -wrap true

#~ ttk::spinbox .spinbox -from 1.0 -to 100.0 -textvariable spinval

.spinbox configure -command { puts [.spinbox get] }

pack .spinbox
