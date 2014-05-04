package require Tk

wm geometry . 450x300+300+350

grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

ttk::style configure WhiteFrame.TFrame -background white
ttk::style configure WhiteLabel.TLabel -background white
ttk::style configure WhiteText.TLabel -background white

ttk::frame .frame
.frame configure -style WhiteFrame.TFrame
grid .frame -column 0 -row 0 -sticky nsew -padx 10

ttk::label .frame.top_label -text "RadioButton Properties" -font { Tahoma 8 bold } -anchor center -justify center
grid .frame.top_label -column 0 -row 0 -columnspan 3 -sticky ew
.frame.top_label configure -style WhiteLabel.TLabel

ttk::separator .frame.hor_sep -orient horizontal
grid .frame.hor_sep -column 0 -row 1 -columnspan 3 -sticky ew
grid columnconfigure .frame 1 -weight 1

ttk::separator .frame.vert_sep -orient vertical
grid .frame.vert_sep -column 1 -row 1 -rowspan 4 -sticky nse -padx 5

ttk::label .frame.name -text "(Name)" -anchor w -justify left
grid .frame.name -column 0 -row 2 -sticky w
.frame.name configure -style WhiteLabel.TLabel

# Label
ttk::label .frame.name_value -text "radioButton1" -font { Tahoma 8 bold } -anchor w -justify left
grid .frame.name_value -column 2 -row 2 -sticky w -padx 5 -pady 2
.frame.name_value configure -style WhiteLabel.TLabel

# Edit box, initially hidden
ttk::entry .frame.name_value_entry
grid .frame.name_value_entry -column 2 -row 2 -sticky w -padx 5 -pady 2
grid remove .frame.name_value_entry
#~ .frame.name_value_entry configure -style WhiteLabel.TEntry

# When double-clicking, forget the widget and add a new entry widget
bind .frame.name_value <Double-ButtonPress-1> {
    grid remove .frame.name_value
    .frame.name_value_entry insert 0 [.frame.name_value cget -text]
    grid .frame.name_value_entry
    .frame.name_value_entry selection range 0 5
}

ttk::label .frame.allow_drop -text "allowDrop" -anchor w -justify left
grid .frame.allow_drop -column 0 -row 3 -sticky w
.frame.allow_drop configure -style WhiteLabel.TLabel

# Put the label and button into its own frame
ttk::frame .frame.allow_drop_value_frame
grid .frame.allow_drop_value_frame -column 2 -row 3 -sticky nsew -padx 5 -pady 2
.frame.allow_drop_value_frame configure -style WhiteFrame.TFrame

# Make sure the column is filled up
grid columnconfigure .frame.allow_drop_value_frame 0 -weight 1

# Add value
ttk::label .frame.allow_drop_value_frame.value -text "false" -anchor w -justify left
grid .frame.allow_drop_value_frame.value -column 0 -row 0 -sticky w
.frame.allow_drop_value_frame.value configure -style WhiteLabel.TLabel

# Add toggle button
image create photo toggle_image -file "icons/toggle.png"
ttk::button .frame.allow_drop_value_frame.toggle -width 1 -image toggle_image -command { .frame.allow_drop_value_frame.value configure -text "true"  }
grid .frame.allow_drop_value_frame.toggle -column 1 -row 0 -sticky e

ttk::label .frame.appearance -text "appearance" -anchor w -justify left
grid .frame.appearance -column 0 -row 4 -sticky w
.frame.appearance configure -style WhiteLabel.TLabel

ttk::combobox .frame.appearance_value -textvariable appearance
.frame.appearance_value configure -values [list NORMAL BUTTON]
.frame.appearance_value set NORMAL

grid .frame.appearance_value -column 2 -row 4 -sticky w -padx 5 -pady 2
