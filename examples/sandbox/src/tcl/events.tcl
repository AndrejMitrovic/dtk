package require Tk

tkwait visibility .

bind . <ButtonPress-1> { puts bla }
#~ event generate . <ButtonPress-1> -when tail
event generate . <ButtonPress-1>

puts [event info]
