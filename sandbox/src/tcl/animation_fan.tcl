##+##########################################################################
#
# Fan.tcl - draws rotating fan blades
# by Keith Vetter, Jan 30, 2004

package require Tk
array set S {title Fan angle 0 increment 2 delay 1
    bg #FCCA04 color black colors 0 blades 3 speed 2}
set colors [list red yellow green blue cyan purple violet white black]

proc DoDisplay {} {
    wm title . $::S(title)
    canvas .c -relief raised -height 250 -width 250 -bg $::S(bg) -bd 2
    label .lspeed -text "Speed:"
    scale .sspeed -orient horizontal -showvalue 0 -variable S(speed) \
        -command Speed -from -20 -to 20
    label .lblades -text "Blades:"
    scale .sblades -orient horizontal -showvalue 0 -variable S(blades) \
        -command DrawFan -from 1 -to 20
    checkbutton .colors -text "C" -font {Helvetica 6 bold} \
        -indicatoron 0 -variable S(colors) -command [list DrawFan 1]
    button .about -text "?" -font {Helvetica 6 bold} \
        -command [list tk_messageBox -title "About $::S(title)" \
                      -message "$::S(title)\nby Keith Vetter, January 2004"]

    bind all <Key-F2> {console show}
    bind .c <Configure> {ReCenter %W %h %w}
    bind .c <Map> {
        Go
    }

    grid .c - - -row 0 -sticky news
    grid .lspeed .sspeed .colors -sticky ew
    grid .lblades .sblades .about -sticky ew
    grid rowconfigure . 0 -weight 1
    grid columnconfigure . 1 -weight 1
}

proc DrawFan {{arg 0}} {
    global S colors

    set b [expr {[set a [expr {360.0 / $S(blades)}]] /2}];# Blade positions
    if {$arg} {
        .c delete all
        set clen [llength $::colors]
        for {set i 0} {$i < $S(blades)} {incr i} {
            set color [expr {! $S(colors) ? $S(color) \
                                 : [lindex $colors [expr {int($clen*rand())}]]}]
            .c create arc $S(size1) -tag blade$i -fill $color -outline $color \
                -start [expr {$S(angle) + $i*$a}] -extent $b
        }
        .c create oval $S(size2) -tag outer -fill $S(bg) -outline $S(bg)
        .c create oval $S(size3) -tag inner -fill $S(color) -outline $S(color)
    } else {                                    ;# Here to just update position
        for {set i 0} {$i < $S(blades)} {incr i} {
            .c itemconfig blade$i -start [expr {$S(angle) + $i * $a}] -extent $b
        }
    }
}
# Recenter -- keeps 0,0 at the center of the canvas during resizing
proc ReCenter {W h w} {                   ;# Called by configure event
    set h2 [expr {$h / 2}] ; set w2 [expr {$w / 2}]
    $W config -scrollregion [list -$w2 -$h2 $w2 $h2]

    set s [expr {($h2 < $w2 ? $h2 : $w2) * .75}];# Blade size
    set ::S(size1) [list -$s -$s $s $s]
    set s [expr {$s / 4}]                       ;# Middle circle
    set ::S(size2) [list -$s -$s $s $s]
    set s [expr {$s / 2}]                       ;# Inner circle
    set ::S(size3) [list -$s -$s $s $s]
    DrawFan -1
}
proc Speed {val} {
    foreach old $::S(increment) ::S(increment) [expr {$val / 4.0}] break
    if {! $old} Go
}
proc Go {} {
    foreach aid [after info] {after cancel $aid};# Be safe
    if {$::S(increment) == 0} return

    set ::S(angle) [expr {$::S(angle) + $::S(increment)}]
    DrawFan
    after $::S(delay) Go
}

DoDisplay
