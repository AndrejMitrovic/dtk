package require Tk

#~ wm minsize . 0 0

#~ tkwait visibility .

update idletasks

wm geometry . 100x100+10+10

#~ puts [wm geometry .]
#~ puts [winfo geometry .]

after idle {
    #~ wm geometry . 100x100+10+10
    #~ puts [wm geometry .]
    puts [winfo geometry .]
}

#~ 100x100+10+10 => 104x100+10+10
#~ 104x100+10+10 => 104x100+10+10
