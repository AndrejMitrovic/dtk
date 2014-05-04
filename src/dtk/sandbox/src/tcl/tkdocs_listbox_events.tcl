package require Tk

wm title . "Listbox"

# note: There is no ttk listbox yet
tk::listbox .listbox -height 10

pack .listbox

set countrynames [list Croatia Slovenia Italy Spain Hungary Austria Germany UK Croatia Slovenia Italy Spain Hungary Austria Germany UK]

.listbox configure -selectmode extended -listvariable countrynames

# clear all selections
.listbox selection clear 0 end

# select some items
.listbox selection set 8

# make sure the selected item is in view
.listbox see 8

bind .listbox <<ListboxSelect>> { puts "Object: currently selected: [.listbox curselection]" }
bind Listbox <<ListboxSelect>> { puts "Class: currently selected: [.listbox curselection]" }
bind . <<ListboxSelect>> { puts "Toplevel: currently selected: [.listbox curselection]" }
bind all <<ListboxSelect>> { puts "All: currently selected: [.listbox curselection]" }
