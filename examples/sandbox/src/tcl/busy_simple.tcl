tkwait visibility .

ttk::button .button1 -text "Button1"
bind .button1 <KeyPress> { puts "Button1: Pressed the '%K' key" }
pack .button1
focus .button1

tk busy hold .button1
label .dummy
focus .dummy
update
