package require Tk

ttk::button .button1 -text "Button1"
ttk::button .button2 -text "Button2"
grid .button1 -row 0 -column 0
grid .button2 -row 0 -column 1

# If empty it uses the default style
puts [.button1 cget -style]

# Print the class of the button
puts [winfo class .button1]

# Set a new style for this widget
# Note: You cannot currently list available styles in a theme
.button1 configure -style "TButton"

# Print all the available themes.
# A theme applies to the entire UI.
puts [ttk::style theme names]

# Print the currently used theme
puts [ttk::style theme use]

# Select a theme
# Doing this replaces all the currently available
# styles with the set of styles defined by the theme.
# Finally, it refreshes all widgets, so that they
# take on the appearance described by the new theme.
ttk::style theme use clam

# Each style represents a single widget type

# A style can set which elements are part of a widget,
# but also defines how those elements are arranged within
# the widget, or in other words, their layout.

# Get the layout of a TButton style
puts [ttk::style layout TButton]

# Note: when you switch to a new theme, the TButton
# is a completely different style which has its own
# layout.
ttk::style theme use winnative

# Note: Ttk uses a simplified version of Tk's "pack" geometry
# manager to specify element layout.
puts [ttk::style layout TButton]

# We know the Button.label element exists, now introspect it
# to see what options it has
puts [ttk::style element options Button.label]

# We can change style options
ttk::style configure TButton -font "helvetica 24"

# Print out all options
puts [ttk::style configure TButton]

# To lookup an option use 'lookup'
puts [ttk::style lookup TButton -font]

# If you modify an existing style, such as "TButton",
# that modification will apply to all widgets using
# that style (so by default, all buttons). That may
# well be what you want to do.
#
# More often, you're interested in creating a new style
# that is similar to an existing one, but varies in a
# certain aspect.

# By prepending another name (e.g. "Emergency") followed
# by a dot onto an existing style, you are implicitly
# creating a new style derived from the existing one.
# So in this example, our new style will have exactly
# the same options as a regular button except for the
# indicated differences:

# Create a derived style
ttk::style configure MyNewStyle -font "helvetica 10" -foreground black -padding 10

ttk::style configure Emergency.TButton -font "helvetica 10" -foreground black -padding 10

# Set the style for a single widget
.button1 configure -style "Emergency.TButton"

proc IfTrue {} {
    return 1
}

# Map how the various configuration options are configured based on widget states
# There are user1/user2/user3 states as well.
.button1 state user3
#~ .button1 state !user3

ttk::style map Emergency.TButton \
	-background [list user3 #0000FF] \
	-foreground [list disabled #a3a3a3] \
	-relief [list {pressed !disabled} sunken] \
	;

# Note: -background which is a font
puts [ttk::style lookup Emergency.TButton -background]

#~ puts [ttk::style lookup Emergency.TButton -relief pressed]

# But this one is a state value
puts [ttk::style lookup Emergency.TButton -background user3]

#
ttk::style theme create my_theme -parent default

#~ puts [ttk::style theme names]
