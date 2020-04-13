#~ grid [ttk::label .little -text "Little"] -column 0 -row 0
#~ grid [ttk::label .bigger -text "Much Bigger Label"] -column 0 -row 0
#~ after 2000 raise .little

set thestate [wm state .]
puts $thestate

wm state . normal
wm iconify .
wm deiconify .
