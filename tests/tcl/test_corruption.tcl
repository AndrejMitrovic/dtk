bind . <ButtonPress-1> { puts "press-1" }
bind . <ButtonRelease-1> { puts "release-1" }
bind . <Double-ButtonPress-1> { puts "double-click-1" }

tkwait visibility .

event generate . <ButtonPress> -button 1
event generate . <ButtonRelease> -button 1
update
after 500
event generate . <ButtonPress> -button 1
