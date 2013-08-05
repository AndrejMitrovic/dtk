package require Tk

wm title . "Scrollbar"

# note: There is no ttk listbox yet
tk::listbox .listbox -height 10

pack .listbox

set countrynames [list Croatia Slovenia Italy Spain Hungary Austria Germany UK Croatia Slovenia Italy Spain Hungary Austria Germany UK]

.listbox configure -selectmode extended -listvariable countrynames

ttk::scrollbar .scrollbar -orient vertical -command { .listbox yview }
.listbox configure -yscrollcommand { .scrollbar set }

pack .scrollbar
