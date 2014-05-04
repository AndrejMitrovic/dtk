package require Tk

ttk::button .button -text "text" -default active -command "puts sometext"
bind .button <Enter> { .button invoke }
bind .button <Return> { .button invoke }
update idletasks

pack .button
