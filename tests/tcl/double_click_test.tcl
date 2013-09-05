# See double-click issue: https://groups.google.com/forum/#!topic/comp.lang.tcl/wbL6ZLrH4gU

bind . <ButtonPress-1> { puts "press-1 %s " }
bind . <ButtonRelease-1> { puts "release-1 %s " }
bind . <Double-ButtonPress-1> { puts "double-click-1 %s " }

bind . <ButtonPress-2> { puts "press-2 %s " }
bind . <ButtonRelease-2> { puts "release-2 %s " }
bind . <Double-ButtonPress-2> { puts "double-click-2 %s " }

tkwait visibility .

# Test button 1 press+release
event generate . <ButtonPress> -button 1
event generate . <ButtonRelease> -button 1

# ignored events, to avoid double-click generation
event generate . <ButtonPress> -button 2
event generate . <ButtonRelease> -button 2

# Test button 2 press+release
event generate . <ButtonPress> -button 2
event generate . <ButtonRelease> -button 2
