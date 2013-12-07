package require Tk

wm title . "Entries"

ttk::entry .name -textvariable username

pack .name

puts "current value is [.name get]"
.name delete 0 end           ; # delete between two indices, 0-based
.name insert 0 "your name"   ; # insert new text at a given index

# Use password-style characters
#~ .name configure -show *
focus .name
.name selection range 2 5
