package require Tk

wm title . "Buttons"

image create photo myimage -file "../button.png"
ttk::button .button -image myimage

place .button -x 0 -y 0
