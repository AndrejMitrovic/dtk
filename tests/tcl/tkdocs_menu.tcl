package require Tk

wm title . "Menu"

option add *tearOff 0

toplevel .win
menu .win.menubar
.win configure -menu .win.menubar

#~ . configure -menu .menubar

set m .win.menubar
#~ set m .menubar
menu $m.file
menu $m.edit
$m add cascade -menu $m.file -label File
$m add cascade -menu $m.edit -label Edit

$m.file add command -label "New" -command "newFile"
$m.file add command -label "Open..." -command "openFile"
$m.file add command -label "Close" -command "closeFile"

$m.file add separator

$m.file add checkbutton -label Check -variable check -onvalue 1 -offvalue 0
$m.file add radiobutton -label One -variable radio -value 1
$m.file add radiobutton -label Two -variable radio -value 2

puts [$m.file entrycget 0 -label]; # get label of top entry in menu
$m.file entryconfigure Close -state disabled; # change an entry
puts [$m.file entryconfigure 0]; # print info on all options for an item

$m add cascade -menu [menu $m.system]
