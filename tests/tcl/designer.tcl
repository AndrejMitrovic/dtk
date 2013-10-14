package require Tk

ttk::frame .tbox
grid .tbox -row 0 -column 0

ttk::button .tbox.button -text "button"
ttk::button .tbox.checkbutton -text "checkbutton"
ttk::button .tbox.combobox -text "combobox"
ttk::button .tbox.entry -text "entry"
ttk::button .tbox.frame -text "frame"
ttk::button .tbox.label -text "label"
ttk::button .tbox.labelframe -text "labelframe"
ttk::button .tbox.listbox -text "listbox"
ttk::button .tbox.notebook -text "notebook"
ttk::button .tbox.pane -text "pane"

grid .tbox.button      -row 0 -column 0
grid .tbox.checkbutton -row 0 -column 1
grid .tbox.combobox    -row 1 -column 0
grid .tbox.entry       -row 1 -column 1
