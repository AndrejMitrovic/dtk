package require Tk 8.6

ttk::button .button1 -text "Button1"
pack .button1

ttk::button .button2 -text "Button2"
pack .button2

#~ proc d_new_callback {args} {
    #~ puts $args
    #~ return 1
#~ }

tkwait visibility .
tkwait visibility .button1
tkwait visibility .button2

#~ proc dtk_focus_request {w} {
    #~ puts [ttk::takefocus .button1]
    #~ return [d_new_callback $w "EventType.focus" "FocusAction.enter"]
#~ }

#~ .button1 configure -takefocus dtk_focus_request

#~ puts [ttk::takefocus .button1]
#~ puts [.button1 instate !disabled]
#~ puts [winfo viewable .button1]

#~ puts [ttk::GuessTakeFocus .]
#~ puts [ttk::GuessTakeFocus .button1]

bind .button1 <ButtonPress-1> {
    event generate .button1 <KeyPress> -keysym Tab
    event generate .button1 <KeyPress> -keysym Tab
    event generate .button1 <KeyPress> -keysym Tab
}


#~ focus .button2
#~ event generate . <KeyPress> -keysym Tab
#~ event generate . <KeyPress> -keysym Tab
#~ event generate . <KeyPress> -keysym Tab
#~ event generate . <KeyPress> -keysym Tab
