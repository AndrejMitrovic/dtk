package require Tk

wm title . "Scrollbar"

tk::listbox .listbox -yscrollcommand ".scrollbar set" -height 5
ttk::scrollbar .scrollbar -command ".listbox yview" -orient vertical
ttk::label .status -text "Status message here" -anchor w
ttk::sizegrip .sizegrip

grid .listbox -column 0 -row 0 -sticky nwes
grid .scrollbar -column 1 -row 0 -sticky ns
grid .status -column 0 -row 1 -sticky we
grid .sizegrip -column 1 -row 1 -sticky se
grid columnconfigure . 0 -weight 1; grid rowconfigure . 0 -weight 1

for {set i 0} {$i<100} {incr i} {
   .listbox insert end "Line $i of 100"
}
