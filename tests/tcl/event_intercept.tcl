package require Tk

ttk::button .button -text "Button"
pack .button

# By default, the bindtags for a widget are:
# { widgetPath, widetClass, widgetToplevel, all }

# We bind some commands
bind .button <Button-1> { puts ".button clicked" }
bind . <Button-1> { puts ". clicked" }

# Note: class is TButton for ttk::button, can use 'winfo' to dynamically get it
set buttonClass [winfo class .button]

# Here, we remove the top level from being invoked when .button is invoked
bindtags .button [list .button $buttonClass all ]

# Now the toplevel is no longer invoked.

# To actually stop the event from propagating to the widget, we have to
# define our own custom tag which is invoked *before* the widgetPath.
# But since we still want to allow the widgetClass to be called (Tk might
# do some special processing in it), we should re-arrange the bindtags
# so the widgetClass is first, the breaking script second, the widgetPath
# third, and 'all' fourth.
bindtags .button [list $buttonClass InterceptEvent .button all ]

# Note: Putting InterceptEvent before the widget class means the button
# will not appear to be physically pressed.
# Putting it after means the button is physically pressed, but it does
# not invoke any command. However it will invoke any commands that are
# bound to the button class itself:

# Binding on class-level still works, since InterceptEvent is set after it
# Note: we have to use '+', otherwise we delete existing bindings instead
# of adding to them, which would end up deleting the widget 'push' animation.
bind $buttonClass <Button-1> "+puts {Some TButton was clicked}"

# Here we have to define which types of events we'll capture, and then
# we call either break or continue. Here is where we will call the D
# callback to ask whether it's ok to propagate this event, which will
# determine if e.g. a button widget is pushed.
bind InterceptEvent <Button-1> { break }

# -- Now let's try with another widget --
ttk::checkbutton .checkbutton -text "Checkbutton" -variable checkbuttonVar -command { puts "command: .checkbutton clicked" }
pack .checkbutton

# Add left-click binding.
bind .checkbutton <Button-1> { puts "bind: .checkbutton clicked" }

# Convenience.
set checkbuttonClass [winfo class .checkbutton]

# We remove the widgetToplevel handler, and at the same time inject our interceptor
# Note: this will not block the -command script, since it's not being blocked by InterceptEvent
#~ bindtags .checkbutton [list $checkbuttonClass InterceptEvent .checkbutton all ]

# The only way to block -command (that I know of), is to actually set the interceptor before the class
#~ bindtags .checkbutton [list InterceptEvent $checkbuttonClass .checkbutton all ]

# Alternatively, we could set the disabled state to true, and maybe avoid
# blocking the event from being propagated.
# -> This changes the physical appearance of the widget, it might not be what we want,
# although we should document it to the user to use this.
#~ .checkbutton state disabled

# maybe we could temporarily remove the 'invoke' command in the button (which should ideally
# route to the single D callback anyway), ala:
#~ bind InterceptEvent <Button-1> { .checkbutton configure -command { }  ;break }

# However this only deletes the command but allows the user to still change the visual appearance.

# Ultimately putting the InterceptEvent first in the bindtags gives us the desired effect of being
# able to catch button clicks (rather than even mouse clicks).
bindtags .checkbutton [list InterceptEvent $checkbuttonClass .checkbutton all ]

# However we don't have to worry about -command, since we can redirect it to the D callback,
# and then let that callback walk through the events before the actual button command is invoked.
# At this point, the "Press" event went through, and we have to create a Command event next.

# Here we intercept FocusIn and FocusOut commands:

# Add commands to focus in for widget, which will be intercepted
bind .checkbutton <FocusIn> { puts ".checkbutton focused in." }
bind .checkbutton <FocusOut> { puts ".checkbutton focused out." }

# Add focus interceptor
bind InterceptEvent <FocusIn> { puts "Intercepted FocusIn event for %W"; break }
bind InterceptEvent <FocusOut> { puts "Intercepted FocusOut event for %W"; break }

# Add commands to virtual traverse for widget, which will be intercepted
bind .checkbutton <<TraverseIn>> { puts ".checkbutton traverse in." }
bind .checkbutton <<TraverseOut>> { puts ".checkbutton traverse out." }

# Add virtual traverse interceptor
bind InterceptEvent <<TraverseIn>> { puts "Intercepted TraverseIn event for %W"; break }
bind InterceptEvent <<TraverseOut>> { puts "Intercepted TraverseOut event for %W"; break }

# Note: Traverse virtual events seem to happen before focus events
# However this does not intercept the actual focus before it happens, maybe that's another command.

# Workaround: We can catch the tab and shift+tab keys
# Note: If the second binding is missing, the first one will match during shift+key
bind InterceptEvent <Key-Tab> { puts "Pressed tab key"; break }
bind InterceptEvent <Shift-Key-Tab> { puts "Pressed shift+tab key"; break }

# To bind to specific characters but not to e.g. ctrl+a, you have to either define these specific
# bindings so they're no-op:
bind . <Key-a> { puts "Pressed a without a modifier %s"; break }
bind . <Control-Key-a> { }
bind . <Alt-Key-a> { }
bind . <Shift-Key-a> { }

# or simply check the %s field for 0:
bind . <Key-b> {if {%s==0} { puts "Pressed b without a modifier %s"; break  }}

# Note: we could bind to a key-press, and then retrieve the key press and any modifiers,
# and use timers to detect whether we have ctrl+shift, or ctrl,shift.
#~ bind . <KeyPress> { puts "Pressed the '%k' key with modifier '%s', keysym string '%K' and decimal '%N'"; break }

# Todo: we should intercept toplevel windows as well.
