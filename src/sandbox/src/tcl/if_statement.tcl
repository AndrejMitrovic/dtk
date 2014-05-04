ttk::button .button

pack .button

#~ bind .button <ButtonPress-1>
    #~ { %W instate !disabled { puts "not disabled" } }

#~ .button state !disabled

# Note: this is an if check below, which calls 'puts' if !disabled is true (if the button is enabled)
#~ bind .button <ButtonPress-1> \
    #~ { %W instate !disabled { puts a } }

#~ tkwait visibility .
#~ tkwait visibility .button

#~ after 1000

.button configure -command { puts "bla" }

ttk::button::activate .button
