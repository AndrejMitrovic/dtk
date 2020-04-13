 #!/bin/wish8.3

  proc - {num1 num2} {
    return [expr {$num1 - $num2}]
  }
  proc + {num1 num2} {
    return [expr {$num1 + $num2}]
  }
  proc * {num1 num2} {
    return [expr {$num1 * $num2}]
  }
  proc / {num1 num2} {
    return [expr {$num1 / $num2}]
  }

  set ::locked 0
  proc updateScale {win first last} {
    if {$::locked} {
      return
    }

    set offset [- $last $first]
    set total [- 1.0 $offset]

    if {$total <= 0.0} {
      return
    }

    set fract [/ 100 $total]
    set pos [* $fract $first]
    set pos [expr int($pos)]

    $win set $pos
  }

  proc scrollText {win pos} {
    if {!$::locked} {
      return
    }
    foreach {first last} [$win yview] break
    set offset [- $last $first]
    set total [- 1.0 $offset]

    if {$total <= 0.0} {
      #avoid divide by 0
      return
    }

    set fract [/ $total 100]
    set newYview [* $fract $pos]
    $win yview moveto $newYview
  }

  proc main {} {
    #pack [scrollbar .s -command ".t yview"] -side left -fill y
    pack [scale .s -show 0 -command {scrollText .t} -from 0 -to 100] -side left -fill y
    bind .s <ButtonPress-1> "set ::locked 1"
    bind .s <ButtonRelease-1> "set ::locked 0"
    pack [text .t -yscrollcommand {updateScale .s} -height 20 -width 20] -side left -fill both -expand 1

    set data "My name is George.\nI like Tcl/Tk most of the time.\nI like Xlib sometimes too.\nWhy is programming so difficult?\n"

    set data [string repeat $data 12]

    .t insert end $data

    #Perhaps with a mixture of tag range and checking which lines are at index @0,0 and index @0,[winfo height .t]
    #we can make text with the elide attribute work properly with scrolling.
    #.t tag add elide_t 10.0 25.0
    .t tag configure elide_t -elide 1
  }
  main
