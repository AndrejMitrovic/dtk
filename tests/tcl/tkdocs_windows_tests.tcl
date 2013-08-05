package require Tk

tkwait visibility .

wm geometry . 100x100+0+0

update idletasks

puts [winfo x .]
