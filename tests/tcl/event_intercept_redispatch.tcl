package require Tk

ttk::button .button -text "Button"
pack .button

bind .button <Button-1> { puts ".button left click" }
.button configure -command { puts ".button invoked" }

set buttonClass [winfo class .button]

bindtags .button [list Interceptor $buttonClass .button all ]

# Testing - We could also call the d callback directly which returns TCL_BREAK or TCL_CONTINUE
bind Interceptor <Button-1> {
    # Call D callback with a request event
    set dtk_intercept_status [my_callback request %W]
    if {$dtk_intercept_status eq 1} {
        break
    } else {

        # Now try invoking the other widget classes, but not Interceptor
        bindtags .button [list $buttonClass .button all ]

        # Here we have to re-generate the event
        event generate .button <Button-1> -when now

        # Call D callback with a notify event
        my_callback notification %W

        # Re-set the binding tags to normal
        bindtags .button [list Interceptor $buttonClass .button all ]

        break
    }
}

proc my_callback {args} {
    puts "callback called with $args"
    return 0
}
