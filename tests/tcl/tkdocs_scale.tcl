package require Tk

wm title . "Scale"

ttk::scale .scale -orient horizontal -length 200 -from 1.0 -to 100.0

.scale configure -value 10.0

puts "current value: [.scale cget -value]"

pack .scale
