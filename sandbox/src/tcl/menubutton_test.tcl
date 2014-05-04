package require Tk

image create photo new_file_icon -file "icons/toolbar/16/New file.png"
image create photo open_file_icon -file "icons/toolbar/16/Open file.png"

menu .menubar -tearoff "0"
. configure -menu ".menubar"

menu .menubar.filemenu -tearoff "0"

.menubar add cascade -menu .menubar.filemenu -label "File"

frame .tbox
pack .tbox -expand 1 -fill both

# File button
ttk::button .tbox.file -text "New File" -underline 0 -image new_file_icon -compound image

# Open button
ttk::menubutton .tbox.open -text "Open file" -underline 0 -direction below -menu .tbox.open.m -image open_file_icon -compound image

menu .tbox.open.m -tearoff 0
.tbox.open.m add command -label "Open file..." -command "puts \"You have selected the first item from the Below menu.\""
.tbox.open.m add command -label "Open recent file..." -command "puts \"You have selected the second item from the Below menu.\""

grid .tbox.file -row 0 -column 0 -sticky nsew
grid .tbox.open -row 0 -column 1 -sticky nsew

grid columnconfigure .tbox 0 -weight 1
grid rowconfigure .tbox 0 -weight 1
