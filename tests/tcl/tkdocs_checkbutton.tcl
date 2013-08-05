package require Tk

wm title . "Checkbuttons"

ttk::checkbutton .check -text "Use Metric" -command "metricChanged" -variable measuresystem -onvalue metric -offvalue imperial

# Stick to north, south, east, west, and set to grid [0, 0]
grid .check -column 0 -row 0 -sticky nsew

.check instate alternate
