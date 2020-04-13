package require Tk

wm title . "Frames"

font create AppHighlightFont -family Helvetica -size 12 -weight bold -overstrike 0 -underline 1
grid [ttk::label .l -text "Attention!" -foreground blue -font AppHighlightFont ]

#~ puts [font families]
