package require Tk

image create photo myimage -file "../small_button.png"

menu .menubar -tearoff "0"
. configure -menu ".menubar"

menu .menubar.filemenu -tearoff "0"

.menubar add cascade -menu .menubar.filemenu -label "File"

frame .body
pack .body -expand 1 -fill both

ttk::menubutton .body.below -text "Below" -underline 0 -direction below -menu .body.below.m -image myimage

menu .body.below.m -tearoff 0
.body.below.m add command -label "Below menu: first item" -command "puts \"You have selected the first item from the Below menu.\""
.body.below.m add command -label "Below menu: second item" -command "puts \"You have selected the second item from the Below menu.\""
grid .body.below -row 0 -column 1 -sticky n
