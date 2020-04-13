package require Tk

tkwait visibility .
#~ bind . <KeyPress> { puts ". key %K" }
#~ bind . <ButtonPress> { puts ". button %b" }

focus .

ttk::button .button -text "Button"
bind . <KeyPress> { puts ". key %K" }
bind .button <KeyPress> { puts ".button key %K" }

pack .button

focus .
#~ focus .button

event generate . <KeyPress> -keysym a
event generate .button <KeyPress> -keysym a
#~ event generate . <KeyPress> -keysym a
#~ event generate . <ButtonPress> -button 1
