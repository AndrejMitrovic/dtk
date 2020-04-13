#~ ttk::progressbar .prog1
#~ grid .prog1 -row 0 -column 0

#~ # Get or set options
#~ puts [ttk::style configure TButton]

#~ # Get a specific option
#~ puts [ttk::style lookup TButton -relief]

#~ puts [ttk::style layout TButton]

#~ puts [ttk::style configure TFrame]

# Get a specific option
#~ puts [ttk::style lookup TFrame -relief]

puts [ttk::style layout TFrame]

ttk::style configure WhiteFrame.TFrame -background white

ttk::frame .frame -borderwidth 5 -relief sunken -width 200 -height 100
grid .frame

.frame configure -style WhiteFrame.TFrame
