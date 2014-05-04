#~ toplevel .tq
#~ button .t.b -text "Helllo world" -command {puts "hello from .t.b"}
#~ pack .t.b
#~ bind .t <Button-1> {puts "hello from the .t"}

# Intercept the event with a break
#~ bindtags .t.b { .t.b Button breakButton .t all }
#~ bind breakButton <1> { break }

#~ puts [bindtags .t.b]

ttk::button .button -text "Button"
pack .button

# By default, the bindtags for a widget are:
# { widgetPath, widetClass, widgetToplevel, all }
bind .button <Button-1> { puts ".button clicked" }
bind . <Button-1> { puts ". clicked" }

# Here, we remove the top level from being invoked when .button is invoked
# Note: class is TButton for ttk::button, can use 'winfo' to dynamically get
bindtags .button [list .button [winfo class .button] all ]

# Now only .button is invoked

# To actually stop the event from propagating to the widget, we have to
# define our own custom tag which is invoked *before* the widgetPath.
# But since we still want to allow the widgetClass to be called (Tk might
# do some special processing in it), we should re-arrange the bindtags
# so the widgetClass is first, the breaking script second, the widgetPath
# third, and 'all' fourth.
bindtags .button [list [winfo class .button] InterceptEvent .button all ]

# Note: Putting InterceptEvent before the widget class means the button
# will not appear to be physically pressed.
# Putting it after means the button is physically pressed, but it does
# not invoke any command.

# Here we have to define which types of events we'll capture, and then
# we call either break or continue (here is where we will call the D
# callback to ask whether it's ok to propagate this event).
bind InterceptEvent <Button-1> { break }
