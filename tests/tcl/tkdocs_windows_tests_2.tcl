package require Tk

#~ tkwait visibility .

wm geometry . 100x100+10+10

update idletasks
puts [wm geometry .]

