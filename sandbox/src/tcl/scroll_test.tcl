package require Tk

wm geometry . 300x200+50+50

tk::listbox .listbox -yscrollcommand ".scrollbar set" -height 5
tk::scrollbar .scrollbar -command ".listbox yview" -orient vertical

grid .listbox -column 0 -row 0 -sticky nwes
grid .scrollbar -column 1 -row 0 -sticky ns
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

for {set i 0} {$i<100} {incr i} {
   .listbox insert end "Line $i of 100"
}
