package require Tk

wm title . "Dialog"

set my_result [tk_messageBox -type "yesno" -message "Are you sure you want to install SuperVirus?" -icon question -title "Install"]
puts "res: $my_result"
