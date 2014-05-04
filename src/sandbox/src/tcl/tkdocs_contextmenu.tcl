package require Tk

wm title . "Context Menu"

option add *tearOff 0

menu .menu
foreach i [list One Two Three] {.menu add command -label $i}
if {[tk windowingsystem]=="aqua"} {
	bind . <2> "tk_popup .menu %X %Y"
	bind . <Control-1> "tk_popup .menu %X %Y"
} else {
	bind . <3> "tk_popup .menu %X %Y"
}
