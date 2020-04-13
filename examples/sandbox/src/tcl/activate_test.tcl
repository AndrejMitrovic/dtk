tkwait visibility .

frame .f -width 150 -height 100
pack .f

tkwait visibility .f

#~ frame .f.f2
#~ pack .f.f2

bind . <Activate> { puts ". activate" }
bind .f <Activate> { puts ".f activate" }
#~ bind .f.f2 <Activate> { puts ".f.f2 activate" }

#~ tkwait visibility .f.f2

#~ event generate . <Activate>
#~ event generate .f <Activate>
#~ event generate .f.f2 <Activate>

