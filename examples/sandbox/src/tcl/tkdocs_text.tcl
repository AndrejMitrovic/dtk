package require Tk

wm title . "Text"

# note: There is no ttk text yet
# note: width and height refer to characters, not pixels
tk::text .t -width 40 -height 10

.t configure -wrap word

#~ .t configure -state disabled
#~ .t configure -state normal

# insert some text at line 1, char 0
# note: line is 1-based, chars are 0-based
.t insert 1.0 foobar\n

# insert some text at line 2, char 0
.t insert 2.0 foobar

.t delete 1.3 1.6

# to get the text (line 1, char 0)
puts "text is: [.t get 1.0 end]"

tkwait visibility .
#~ tkwait visibility .t

puts [.t cget -width]
puts [winfo width .t]

pack .t
