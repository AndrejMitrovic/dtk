package require Tk

tkwait visibility .
bind . <ButtonPress> { puts ". key %K" }

#~ focus .

#~ event generate . <KeyPress> -keysym a
event generate . <ButtonPress> -button 1
