package require Tk

tkwait visibility .

grid [ttk::entry .e1 -textvariable var1]
grid [ttk::entry .e2 -textvariable var2]

#~ bindtags .e1 { .doesNotExist }
#~ bindtags .e2 { .doesNotExist }

#~ We should map a FocusOut on the parent widget, and then re-call FocusIn on
#~ the parent widget

bind all <FocusIn> { break }

#~ bind all <FocusOut> { focus .e1 }

#~ bind all <KeyPress> { puts blabla }

#~ bind . <FocusIn> { puts "Focused in to : %W" }
#~ bind all <FocusOut> { puts "Focused out of: %W" }
#~ bind . <<TraverseOut>> { puts "Traversed out of: %W" }
#~ bind . <<TraverseIn>> { puts "Traversed in to: %W" }
