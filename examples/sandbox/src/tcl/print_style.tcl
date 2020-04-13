ttk::progressbar .prog1
grid .prog1 -row 0 -column 0

puts [ttk::style configure TButton -foobar 1]

# If empty it uses the default style
#~ puts [.prog1 cget -style]

#~ .prog1 configure -style "Vertical.TProgressbar"
#~ puts [.prog1 cget -style]

#~ .button1 configure -style
