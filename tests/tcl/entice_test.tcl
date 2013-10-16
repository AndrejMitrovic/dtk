package require Tk

wm geometry . 450x300+300+350

grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

ttk::style configure WhiteFrame.TFrame -background white
ttk::style configure WhiteLabel.TLabel -background white
ttk::style configure WhiteText.TLabel -background white

ttk::frame .frame
.frame configure -style WhiteFrame.TFrame
grid .frame -column 0 -row 0 -sticky nsew

ttk::label .frame.top_label -text "RadioButton Properties" -font { Tahoma 8 bold } -anchor center -justify center
grid .frame.top_label -column 0 -row 0 -columnspan 3 -sticky ew
.frame.top_label configure -style WhiteLabel.TLabel

ttk::separator .frame.hor_sep -orient horizontal
grid .frame.hor_sep -column 0 -row 1 -columnspan 3 -sticky ew
grid columnconfigure .frame 1 -weight 1

ttk::separator .frame.vert_sep -orient vertical
grid .frame.vert_sep -column 1 -row 1 -rowspan 4 -sticky nse -padx 10

ttk::label .frame.name -text "(Name)" -anchor w -justify left
grid .frame.name -column 0 -row 2 -sticky w
.frame.name configure -style WhiteLabel.TLabel

ttk::label .frame.name_value -text "radioButton1" -font { Tahoma 8 bold } -anchor w -justify left
grid .frame.name_value -column 2 -row 2 -sticky w
.frame.name_value configure -style WhiteLabel.TLabel

ttk::label .frame.allow_drop -text "allowDrop" -anchor w -justify left
grid .frame.allow_drop -column 0 -row 3 -sticky w
.frame.allow_drop configure -style WhiteLabel.TLabel

ttk::label .frame.allow_drop_value -text "false" -anchor w -justify left
grid .frame.allow_drop_value -column 2 -row 3 -sticky w
.frame.allow_drop_value configure -style WhiteLabel.TLabel

ttk::label .frame.appearance -text "appearance" -anchor w -justify left
grid .frame.appearance -column 0 -row 4 -sticky w
.frame.appearance configure -style WhiteLabel.TLabel

ttk::combobox .frame.appearance_value -textvariable appearance
.frame.appearance_value configure -values [list NORMAL BUTTON]
.frame.appearance_value set NORMAL

grid .frame.appearance_value -column 2 -row 4 -sticky w
