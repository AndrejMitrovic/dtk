package require Tk

tkwait visibility .

wm geometry . 100x100+0+0

update idletasks

#~ puts [winfo x .]

ttk::button .b -text hello -command { puts [winfo x .b] }

pack .b
