package require Tk

wm title . "Labels"

ttk::label .label -text {Full name:}

#~ ttk::frame .myframe -padding "3 3 12 12" -width 100 -height 100
#~ .myframe configure -borderwidth 2 -relief sunken

# Stick to north, south, east, west, and set to grid [0, 0]
grid .label -column 0 -row 0 -sticky nsew

# Use textvariable to update the display based on a variable
.label configure -textvariable resultContents
set resultContents "New value to display"

# Displaying an image
image create photo imgobj -file "dmc2.gif"
.label configure -image imgobj

# Display both the image and the text
.label configure -compound center

# Set what edge the label should be attached to
.label configure -anchor se

# Set text wrapping
.label configure -wraplength 50

# Set text justification
.label configure -justify right

# Set colors
.label configure -foreground red
.label configure -foreground #0000ff

# A lable can have a relief just like a frame
.label configure -relief sunken

#~ # Follow the window size for item in grid [0, 0]
#~ grid columnconfigure . 0 -weight 1
#~ grid rowconfigure . 0 -weight 1
