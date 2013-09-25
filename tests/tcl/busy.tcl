ttk::button .button1 -text "Button1"
bind .button1 <KeyPress> { puts "Button1: Pressed the '%K' key" }
pack .button1

ttk::button .button2 -text "Button2"
bind .button2 <KeyPress> { puts "Button2: Pressed the '%K' key" }
pack .button2
focus .button2

tk busy hold .button1
update
