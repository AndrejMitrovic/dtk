package require Tk

pack [button .b1 -default active -text b1 -command "puts inactive"] -side left
pack [button .b2 -default disabled -text b2 -command "puts inactive"]

#~ ttk::button .button1 -text "inactive" -default disabled -command "puts inactive"
#~ ttk::button .button2 -text "active" -default active -command "puts active"

#~ bind . <Return> { .button1 invoke }
#~ update idletasks

#~ pack .button1
#~ pack .button2
