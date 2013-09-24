package require Tk

wm title . "Grid2"

ttk::frame .frame -padding "3 3 12 12"
grid .frame -column 0 -row 0 -sticky nsew

ttk::label .frame.nameLabel -text Name
ttk::entry .frame.name

ttk::checkbutton .frame.one -text One -variable one -onvalue 1; set one 1
ttk::checkbutton .frame.two -text Two -variable two -onvalue 1; set two 0
ttk::checkbutton .frame.three -text Three -variable three -onvalue 1; set three 1

ttk::button .frame.ok -text Okay -command { puts [grid bbox .frame] }
ttk::button .frame.cancel -text Cancel

ttk::frame .frame.emptyFrame -borderwidth 5 -relief sunken -width 200 -height 100

# Span makes widgets occupy multiple cells in the grid
grid .frame.nameLabel -column 3 -row 0 -columnspan 2 -sticky nw -padx 5
grid .frame.name -column 3 -row 1 -columnspan 2 -sticky new -pady 5 -padx 5

grid .frame.one -column 0 -row 3
grid .frame.two -column 1 -row 3
grid .frame.three -column 2 -row 3

grid .frame.ok -column 3 -row 3
grid .frame.cancel -column 4 -row 3

puts [grid configure .frame.emptyFrame -row]

#~ grid .frame.emptyFrame
#~ grid .frame.emptyFrame -column 0 -row 0 -columnspan 3 -rowspan 2 -sticky nsew

# Every column and row has a "weight" grid option associated with it,
# which tells it how much it should grow if there is extra room in the
# master to fill. By default, the weight of each column or row is 0,
# meaning don't expand to fill space.
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1
grid columnconfigure .frame 0 -weight 3
grid columnconfigure .frame 1 -weight 3
grid columnconfigure .frame 2 -weight 3
grid columnconfigure .frame 3 -weight 1
grid columnconfigure .frame 4 -weight 1
grid rowconfigure .frame 1 -weight 1

#~ puts "slaves of .frame are: [grid slaves .frame]"
#~ puts "slaves of .frame in row 3 are: [grid slaves .frame -row 3]"
#~ puts "slaves of .frame in column 0 are: [grid slaves .frame -column 0]"
#~ puts "grid info for .frame.nameLabel: [grid info .frame.nameLabel]"
#~ grid configure .frame.nameLabel -sticky ew
#~ puts "grid info for .frame.nameLabel: [grid info .frame.nameLabel]"

#~ tkwait visibility .
