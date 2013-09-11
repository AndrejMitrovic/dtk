package require Tk

ttk::button .button -text "Button"
pack .button

bind .button <Button-1> { puts ".button left click" }
.button configure -command { puts ".button invoked" }

set buttonClass [winfo class .button]

bindtags .button [list Interceptor $buttonClass .button all ]

# Attempt 1: Reconfigure bindtags, directly call widget class handler
#~ bind Interceptor <Button-1> {
    #~ # Call D callback with a request event
    #~ set dtk_intercept_status [my_callback request %W]
    #~ if {$dtk_intercept_status eq 1} {
        #~ break
    #~ } else {
        #~ set widgetClass [winfo class %W]

        #~ # Now try invoking the other widget classes, but not Interceptor
        #~ bindtags %W [list $widgetClass %W all ]

        #~ # Here we have to re-generate the event
        #~ event generate %W <Button-1> -when now

        #~ # Call D callback with a notify event
        #~ my_callback notification %W

        #~ # Re-set the binding tags to normal
        #~ bindtags %W [list Interceptor $widgetClass %W all ]

        #~ break
    #~ }
#~ }

# Attempt 2: Schedule a D callback event at the end of the queue
bind Interceptor <Button-1> {
    # Call D callback with a request event
    set dtk_intercept_status [my_callback request %W]
    if {$dtk_intercept_status eq 1} {
        break
    } else {
        set widgetClass [winfo class %W]

        continue

        # Here we have to re-generate the event, but schedule it for later
        # (note: we have to tag it as a notification)
        event generate %W <Button-1> -when now

        break
    }
}

proc my_callback {args} {
    puts "callback called with $args"
    return 0
}
