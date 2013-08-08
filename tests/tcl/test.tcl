#~ bind . <Enter> { dtk::call0 Enter %x %y %k %K %w %h %X %Y }
#~ bind . <Leave> { dtk::call0 Leave %x %y %k %K %w %h %X %Y }
tkwait visibility .
ttk::frame .ttk__frame305437440 -padding "0 0 0 0"
#~ bind .ttk__frame305437440 <Enter> { dtk::call1 Enter %x %y %k %K %w %h %X %Y }
#~ bind .ttk__frame305437440 <Leave> { dtk::call1 Leave %x %y %k %K %w %h %X %Y }
.ttk__frame305437440 configure -width "100"
.ttk__frame305437440 configure -height "100"
.ttk__frame305437440 configure -borderwidth "2"
.ttk__frame305437440 configure -relief  "sunken"
pack .ttk__frame305437440
