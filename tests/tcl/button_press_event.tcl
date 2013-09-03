ttk::button .button -text "Button"
pack .button

bind .button <Button-1> { puts "Pressed Mouse 1 while over .button, at: %t" }
.button configure -command { puts "Depressed .button at: %t" }
