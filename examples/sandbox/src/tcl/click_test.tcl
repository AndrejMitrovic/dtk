# See double-click issue: https://groups.google.com/forum/#!topic/comp.lang.tcl/wbL6ZLrH4gU

bind . <Activate> { puts "Activated ." }
bind . <FocusIn> { puts "Focused ." }

tkwait visibility .

event generate . <Activate>

# Test button 1 press+release
#~ event generate . <ButtonPress> -button 1
#~ event generate . <ButtonPress> -button 2

#~ event generate . <ButtonPress> -button 1 -state 65536
