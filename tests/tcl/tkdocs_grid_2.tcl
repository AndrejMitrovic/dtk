package require Tk

wm title . "Grid2"

ttk::frame .c -padding "3 3 12 12"
ttk::frame .c.f -borderwidth 5 -relief sunken -width 200 -height 100
ttk::label .c.namelbl -text Name
ttk::entry .c.name
ttk::checkbutton .c.one -text One -variable one -onvalue 1; set one 1
ttk::checkbutton .c.two -text Two -variable two -onvalue 1; set two 0
ttk::checkbutton .c.three -text Three -variable three -onvalue 1; set three 1
ttk::button .c.ok -text Okay
ttk::button .c.cancel -text Cancel

grid .c -column 0 -row 0 -sticky nsew
grid .c.f -column 0 -row 0 -columnspan 3 -rowspan 2 -sticky nsew
grid .c.namelbl -column 3 -row 0 -columnspan 2 -sticky nw -padx 5
grid .c.name -column 3 -row 1 -columnspan 2 -sticky new -pady 5 -padx 5
grid .c.one -column 0 -row 3
grid .c.two -column 1 -row 3
grid .c.three -column 2 -row 3
grid .c.ok -column 3 -row 3
grid .c.cancel -column 4 -row 3

grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1
grid columnconfigure .c 0 -weight 3
grid columnconfigure .c 1 -weight 3
grid columnconfigure .c 2 -weight 3
grid columnconfigure .c 3 -weight 1
grid columnconfigure .c 4 -weight 1
grid rowconfigure .c 1 -weight 1

puts "slaves of .c are: [grid slaves .c]"
puts "slaves of .c in row 3 are: [grid slaves .c -row 3]"
puts "slaves of .c in column 0 are: [grid slaves .c -column 0]"
puts "grid info for .c.namelbl: [grid info .c.namelbl]"
grid configure .c.namelbl -sticky ew
puts "grid info for .c.namelbl: [grid info .c.namelbl]"
