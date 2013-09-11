package require Tk

wm geometry . 300x200+50+50

tk::listbox .listbox -yscrollcommand ".scrollbar set" -height 5
tk::scrollbar .scrollbar -command ".listbox yview" -orient vertical

#~ pack .vpane.files.workdir.sx -side bottom -fill x
#~ pack .vpane.files.workdir.sy -side right -fill y

pack .scrollbar -side right -fill x -fill y
pack .listbox -side right -fill x -fill y
#~ pack columnconfigure . 0 -weight 1
#~ pack rowconfigure . 0 -weight 1

for {set i 0} {$i<100} {incr i} {
   .listbox insert end "Line $i of 100"
}
