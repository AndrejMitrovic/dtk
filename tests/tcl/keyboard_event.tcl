package require Tk

tkwait visibility .
bind . <KeyPress> { puts ". key %K" }
bind . <ButtonPress> { puts ". button %b" }

focus .

event generate . <KeyPress> -keysym a
event generate . <ButtonPress> -button 1
