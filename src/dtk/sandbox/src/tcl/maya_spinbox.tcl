package require Tk

wm title . "Spinbox"

ttk::spinbox .spinbox -from -50.0 -to 50.0 -wrap true
.spinbox set 0

pack .spinbox

bind .spinbox <ButtonPress-1> "+ onpress %W %x %y"
bind .spinbox <ButtonRelease-1> "+ onrelease %W"
bind .spinbox <Motion> "+ onmove %W %x %y %X %Y %s"

set is_button_click 0

proc onrelease {w} {
    global is_button_click
    set is_button_click 0
}

proc onpress {w x y} {
    global is_button_click

    if {[$w instate disabled]} { return }
    focus $w
    switch -glob -- [$w identify $x $y] {
        *textarea	{ set is_button_click 0 }
        *rightarrow	-
        *uparrow -
        *leftarrow -
        *downarrow	{ set is_button_click 1 }
	}
}

proc onmove {w x y X Y state} {
    global is_button_click
    if {[$w instate disabled]} { return }
    focus $w

    if {$is_button_click && $state == 256} {
        set half [expr {[winfo height $w] / 2}]
        set center [expr {[winfo rooty $w] + $half}]
        set diff [expr {$Y - $center}]

        set value [expr { -$diff}]

        set from [$w cget -from]
        set to [$w cget -to]

        set value [::tcl::mathfunc::max $value $from]
        set value [::tcl::mathfunc::min $value $to]

        $w set $value
    }
}
