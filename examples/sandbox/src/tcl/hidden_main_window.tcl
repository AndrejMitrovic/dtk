package require Tk

tk::toplevel .window

bind .window <Destroy> { destroy . }

wm geometry . 1x1+0+0
wm overrideredirect . 1
wm attributes . -alpha 0
wm transient .
