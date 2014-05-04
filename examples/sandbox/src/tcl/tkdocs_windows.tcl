package require Tk

# The initial main window here is '.', but we could create a new one with:
tk::toplevel .window
destroy .window

wm title . "Menu"

set old_title [wm title .]
puts "old title: $old_title"
wm title . "New title"

wm geometry . 300x200+350+350

#~ puts "stack order: [wm stackorder .]"
#~ puts "stack order: [wm stackorder .window2]"

tk::toplevel .window

# Have to wait for the window to be mapped first
tkwait visibility .

puts [wm stackorder .]
puts [wm stackorder .window]

if {[wm stackorder .window isabove .]} { puts ".window is above ." }
if {[wm stackorder . isabove .window]} { puts ". is above .window" }

raise .window

if {[wm stackorder .window isabove .]} { puts ".window is above ." }
if {[wm stackorder . isabove .window]} { puts ". is above .window" }

# Make window not resizable
wm resizable .window 0 0

# Make window resizable but only horizontally
wm resizable .window 1 0

wm resizable .window 1 1

wm minsize .window 200 100
wm maxsize .window 500 500

set window_state [wm state .window]
puts "window state: $window_state"
wm state .window normal
wm iconify .window
#~ wm deiconify .window
