# See double-click issue: https://groups.google.com/forum/#!topic/comp.lang.tcl/wbL6ZLrH4gU

bind . <Motion> { puts "press %b %s " }

# Test button 1 press+release
#~ event generate . <ButtonPress> -button 1
#~ event generate . <ButtonPress> -button 2

tkwait visibility .

#~ event generate . <ButtonPress> -button 1 -state 65536
