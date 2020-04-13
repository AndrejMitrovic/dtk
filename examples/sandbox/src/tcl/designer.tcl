package require Tk

wm geometry . 500x300+400+350

# Top toolbuttons
#~ frame

image create photo new_file_icon -file "icons/toolbar/16/New file.png"
image create photo open_file_icon -file "icons/toolbar/16/Open file.png"

frame .tbox
grid .tbox -row 0 -column 0 -sticky w

# File button
ttk::button .tbox.file -underline 0 -image new_file_icon -compound image
grid .tbox.file -row 0 -column 0

# Open button
ttk::button .tbox.open -underline 0 -image open_file_icon -compound image
grid .tbox.open -row 0 -column 1


#~ ttk::menubutton .tbox.open -text "Open file" -underline 0 -direction below -menu .tbox.open.m -image open_file_icon -compound image

#~ menu .tbox.open.m -tearoff 0
#~ .tbox.open.m add command -label "Open file..." -command "puts \"You have selected the first item from the Below menu.\""
#~ .tbox.open.m add command -label "Open recent file..." -command "puts \"You have selected the second item from the Below menu.\""

#~ grid .tbox.file -row 0 -column 0 -sticky nsew
#~ grid .tbox.open -row 0 -column 1 -sticky nsew

#~ grid columnconfigure .tbox 0 -weight 1
#~ grid rowconfigure .tbox 0 -weight 1

# Project selector
ttk::notebook .selector
ttk::frame .selector.proj_frame_1; # first page, which would get widgets gridded into it
ttk::frame .selector.proj_frame_2; # second page
.selector add .selector.proj_frame_1 -text "Project 1"
.selector add .selector.proj_frame_2 -text "Project 2"

# Toolbox stays put but the selector widget grows vertically
grid rowconfigure . 0 -weight 0
grid rowconfigure . 1 -weight 1

# Horizontally they both grow
grid columnconfigure . 0 -weight 1

# Widget toolbox
set wbox [ttk::frame .selector.proj_frame_1.wbox_frame]
grid $wbox -row 0 -column 0 -sticky nsew

grid [ttk::label  $wbox.description -text "Widgets"     ] -row 0 -column 0 -columnspan 2 -sticky w
grid [ttk::button $wbox.button -text "button"           ] -row 1 -column 0
grid [ttk::button $wbox.checkbutton -text "checkbutton" ] -row 1 -column 1
grid [ttk::button $wbox.combobox -text "combobox"       ] -row 2 -column 0
grid [ttk::button $wbox.entry -text "entry"             ] -row 2 -column 1
grid [ttk::button $wbox.frame -text "frame"             ] -row 3 -column 0
grid [ttk::button $wbox.label -text "label"             ] -row 3 -column 1
grid [ttk::button $wbox.labelframe -text "labelframe"   ] -row 4 -column 0
grid [ttk::button $wbox.listbox -text "listbox"         ] -row 4 -column 1
grid [ttk::button $wbox.notebook -text "notebook"       ] -row 5 -column 0
grid [ttk::button $wbox.pane -text "pane"               ] -row 5 -column 1
grid [ttk::button $wbox.progressbar -text "progressbar" ] -row 6 -column 0
grid [ttk::button $wbox.radiobutton -text "radiobutton" ] -row 6 -column 1
grid [ttk::button $wbox.separator -text "separator"     ] -row 7 -column 0
grid [ttk::button $wbox.slider -text "slider"           ] -row 7 -column 1
grid [ttk::button $wbox.spinbox -text "spinbox"         ] -row 8 -column 0
grid [ttk::button $wbox.text -text "text"               ] -row 8 -column 1
grid [ttk::button $wbox.tree -text "tree"               ] -row 9 -column 0

grid .selector -row 1 -column 0 -rowspan 10 -sticky nsew

# The Edit and Inspector frames are in a pane
set right_pane [ttk::panedwindow .selector.proj_frame_1.right_pane -orient horizontal]

# Edit frame
set edit [ttk::frame $right_pane.edit_frame]
$edit configure -relief sunken -borderwidth 10
grid $edit -row 0 -column 1 -sticky nsew -padx 10

# The Toolbox frame does not grow
grid columnconfigure .selector.proj_frame_1 0 -weight 0

# The Pane frame grows horizontally
grid columnconfigure .selector.proj_frame_1 1 -weight 1

# Inspector frame
set inspector [ttk::frame $right_pane.inspector_frame]

ttk::style configure WhiteFrame.TFrame -background white
$inspector configure -style WhiteFrame.TFrame

grid $inspector -row 0 -column 2 -sticky nsew
$inspector configure -borderwidth 10 -width 150

# The Toolbox/Edit/Inspector frames grow vertically
grid rowconfigure .selector.proj_frame_1 0 -weight 1

# Add the Edit and Inspector to the pane
$right_pane add $edit
$right_pane add $inspector

# Set the pane to the second column
grid $right_pane -row 0 -column 1 -sticky nsew -padx 10
grid columnconfigure .selector.proj_frame_1 1 -weight 1

# The Edit pane grows horizontally
$right_pane pane 0 -weight 1

# The inspector pane is fixed to the user setting
$right_pane pane 1 -weight 0

# Edit the inspector frame
grid [ttk::label $inspector.description -text "Inspector"] -row 0 -column 0 -columnspan 2 -sticky ew
grid [ttk::label $inspector.text_label -text "Text:"] -row 1 -column 0
grid [ttk::label $inspector.text] -row 1 -column 1

$wbox.button configure -command { $inspector.text configure -text "Button" }
