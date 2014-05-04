package require Tk

tkwait visibility .

grid [ttk::frame .myframe -padding "3 3 12 12"] -column 0 -row 0 -sticky nwes
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1
#~ ttk::frame .myframe -padding "3 3 12 12" -width 100 -height 100
#~ pack .myframe

#~ bind .myframe <Configure> { puts "border width: %B" }
.myframe configure -borderwidth 10
