package require Tk

ttk::button .button1 -text "Button1"
ttk::button .button2 -text "Button2"
grid .button1 -row 0 -column 0
grid .button2 -row 0 -column 1

puts [ttk::style layout TButton]
