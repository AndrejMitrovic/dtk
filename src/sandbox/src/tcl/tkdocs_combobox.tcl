package require Tk

wm title . "Comboboxes"

ttk::combobox .country -textvariable country

pack .country

.country configure -values [list USA Canada Australia]

bind .country <<ComboboxSelected>> { script }
