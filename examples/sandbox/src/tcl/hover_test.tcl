package require Tk

ttk::button .button -text "button"
ttk::button .button2 -text "button2"
pack .button
pack .button2

#~ bind .button <Enter> { puts [winfo width .button] }
bind .button <Enter> { puts "Enter: %m %s %t" }
bind .button <Leave> { puts "Leave: %m %s %t" }
bind .button <FocusIn> { puts "Enter: %m %s %t" }
bind .button <FocusOut> { puts "Leave: %m %s %t" }

tkwait visibility .

#~ wm geometry .button 150x200+110+110

#~ puts [winfo width .button]
