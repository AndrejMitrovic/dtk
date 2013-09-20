package require Tk

ttk::frame .myframe -padding "5 5 5 5" -width 100 -height 100

grid .myframe -column 0 -row 0 -sticky nsew

#~ bind .myframe <Configure> { puts "border width: %B, width: %w, height: %h" }
#~ .myframe configure -borderwidth 10 -relief sunken

bind . <Configure> { puts "window .: border width: %B, width: %w, height: %h" }
wm geometry . 150x200+250+200
update idletasks

puts [winfo id .myframe]
