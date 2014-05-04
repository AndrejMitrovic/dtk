package require Tk

wm geometry . 450x300+300+350

grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

ttk::frame .frame
grid .frame -column 0 -row 0 -sticky nsew

ttk::label .frame.top_label -text "RadioButton Properties" -anchor center
grid .frame.top_label -column 0 -row 0 -columnspan 2 -sticky ew

ttk::separator .frame.hor_sep -orient horizontal
grid .frame.hor_sep -column 0 -row 1 -columnspan 3 -sticky ew
grid columnconfigure .frame 1 -weight 1

ttk::separator .frame.vert_sep -orient vertical
grid .frame.vert_sep -column 1 -row 1 -rowspan 4 -sticky ns

ttk::label .frame.name -text "(Name)" -anchor w -justify left
grid .frame.name -column 0 -row 2

ttk::label .frame.name_value -text "radioButton1" -font { Tahoma 8 bold } -anchor w -justify left
grid .frame.name_value -column 2 -row 2

ttk::label .frame.allow_drop -text "allowDrop" -anchor w -justify left
grid .frame.allow_drop -column 0 -row 3

ttk::label .frame.allow_drop_value -text "false" -anchor w -justify left
grid .frame.allow_drop_value -column 2 -row 3

ttk::label .frame.appearance -text "appearance" -anchor w -justify left
grid .frame.appearance -column 0 -row 4

ttk::combobox .frame.appearance_value -textvariable appearance
.frame.appearance_value configure -values [list NORMAL BUTTON]

grid .frame.appearance_value -column 2 -row 4
