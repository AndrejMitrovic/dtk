# See double-click issue: https://groups.google.com/forum/#!topic/comp.langcl/wbL6ZLrH4gU

#~ bind . <Activate> { puts "Activated ." }
#~ bind . <FocusIn> { puts "Focused ." }

tkwait visibility .

#~ event generate . <Activate>

# Test button 1 press+release
#~ event generate . <ButtonPress> -button 1
#~ event generate . <ButtonPress> -button 2

#~ event generate . <ButtonPress> -button 1 -state 65536

frame .f -width 150 -height 100
pack .f
#~ focus -force .f
#~ update

#~ tkwait visibility .f

bind .f <Activate> "set x {event Activate}"
#~ set x xyzzy
event generate .f <Activate>
#~ list $x [bind .f]
