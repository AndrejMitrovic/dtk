package require Tk 8.5

namespace eval ::nscale {
    variable options
    variable State

    bind NScale <Destroy>         {::nscale::Cleanup %W}
    bind NScale <ButtonPress-1>   {::nscale::Press %W %x %y}
    bind NScale <B1-Motion>       {::nscale::Drag %W %x %y}
    bind NScale <ButtonRelease-1> {::nscale::Release %W %x %y}

    bind NScale <ButtonPress-2>   {::nscale::Jump %W %x %y}
    bind NScale <B2-Motion>       {::nscale::Drag %W %x %y}
    bind NScale <ButtonRelease-2> {::nscale::Release %W %x %y}

    bind NScale <ButtonPress-3>   {::nscale::Jump %W %x %y}
    bind NScale <B3-Motion>       {::nscale::Drag %W %x %y}
    bind NScale <ButtonRelease-3> {::nscale::Release %W %x %y}

    bind NScale <Left>            {::nscale::Increment %W [expr {[%W cget -increment] * -1}]}
    bind NScale <Up>              {::nscale::Increment %W [expr {[%W cget -increment] * -1}]}
    bind NScale <Right>           {::nscale::Increment %W [%W cget -increment]}
    bind NScale <Down>            {::nscale::Increment %W [%W cget -increment]}
    bind NScale <Control-Left>    {::nscale::Increment %W [expr {[%W cget -bigincrement] * -1}]}
    bind NScale <Control-Up>      {::nscale::Increment %W [expr {[%W cget -bigincrement] * -1}]}
    bind NScale <Control-Right>   {::nscale::Increment %W [%W cget -bigincrement]}
    bind NScale <Control-Down>    {::nscale::Increment %W [%W cget -bigincrement]}
    bind NScale <Home>            { %W set [%W cget -from] }
    bind NScale <End>             { %W set [%W cget -to] }
}

proc ::nscale::scale {w args} {
    variable options

    ttk::scale $w {*}[dict remove $args -increment -bigincrement -class] \
        -class NScale
    foreach opt {-increment -bigincrement} val {1 10} {
        if [dict exists $args $opt] {
            dict set options $w $opt [dict get $args $opt]
        } else {
            dict set options $w $opt $val
        }
    }

    bindtags $w [list $w NScale [winfo toplevel $w] all]

    rename ::$w [namespace current]::$w
    interp alias {} ::$w {} ::nscale::Dispatch $w
    return $w
}

proc ::nscale::Dispatch {w method args} {
    switch -- $method {
        cg - cge -
        cget {
            return [Cget $w {*}$args]
        }
        co - con - conf - confi - config - configu - configur -
        configure {
            return [Configure $w {*}$args]
        }
        default {
            return [$w $method {*}$args]
        }
    }
}

proc ::nscale::Cget {w args} {
    variable options

    if {[llength $args] != 1} {
        return -code error -level 2 "wrong # args: should be \"$w\" cget option"
    }
    set option [lindex $args 0]
    if {$option ni {-increment -bigincrement}} {
        # the real widget is in our namespace
        return [$w cget $option]
    }
    return [dict get $options $w $option]
}

proc ::nscale::Configure {w args} {
    variable options

    switch -- [llength $args] {
        0 {
            set res [$w configure]
            lappend res [list -increment [dict get $options $w -increment]]
            lappend res [list -bigincrement [dict get $options $w -bigincrement]]
            return $res
        }
        1 {
            set opt [lindex $args 0]
            if {$opt in {-increment -bigincrement}} {
                return [dict get $options $w $opt]
            }
            return [$w configure $opt]
        }
        default {
            if {[llength $args] & 1} {
                return -code error -level 2 "wrong # args: should be \"$w\"\
                configure option ?value? ?option value?"
            }
            foreach {k v} $args {
                if {$k in {-increment -bigincrement}} {
                    dict set options $w $k $v
                } else {
                    $w configure $k $v
                }
            }
        }
    }
}

proc ::nscale::Cleanup {w} {
    variable options

    rename ::$w {}
    dict unset options $w
}

proc ::nscale::Press {w x y} {
    variable State
    set State(dragging) 0

    switch -glob -- [$w identify $x $y] {
        *track -
        *trough {
            set inc [::$w cget -increment]
            set inc [expr {
                ((([$w get $x $y] - [$w get]) * $inc) < 0) ?
                -1 * $inc : $inc
                }]
            ttk::Repeatedly Increment $w $inc
        }
        *slider {
            set State(dragging) 1
            set State(initial) [$w get]
        }
    }
}

proc ::nscale::Jump {w x y} {
    variable State
    set State(dragging) 0

    switch -glob -- [$w identify $x $y] {
        *track -
        *trough {
            $w set [Adjust $w [$w get $x $y]]
            set State(dragging) 1
            set State(initial) [$w get]
        }
        *slider {
            Press $w $x $y
        }
    }
}

proc ::nscale::Drag {w x y} {
    variable State
    if {$State(dragging)} {
        $w set [Adjust $w [$w get $x $y]]
    }
}

proc ::nscale::Release {w x y} {
    variable State
    set State(dragging) 0
    ttk::CancelRepeat
}

proc ::nscale::Increment {w delta} {
    if {![winfo exists $w]} return
    $w set [expr {[$w get] + $delta}]
}

proc ::nscale::Adjust {w value} {
    set f [$w cget -from]
    set i [::$w cget -increment]
    return [expr {$f + int(($value - $f) / $i) * $i}]
}

::nscale::scale .foo
pack .foo
