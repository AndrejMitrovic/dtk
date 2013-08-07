package require Tk

ttk::button .button -text "one two three four five" -width -100 -width 5
bind .button <Return> { .button invoke }

pack .button
