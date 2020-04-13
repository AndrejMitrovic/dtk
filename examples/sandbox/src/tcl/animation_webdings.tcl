package require Tk

 pack [text .t -font {Webdings 48} -width 17 -height 4]
 .t insert end [string repeat " " 30]j\n
 .t insert end ABCDEFGHIJKMPQRST\n
 .t insert end "[string repeat " " 30]h h\n"
 .t insert end ABCDEFGHIJKMPQRST\n
 update
 after 500
 for {set i 0} {$i <= 64} {incr i} {
    if {$i<31} {.t delete 1.0}
    if {$i%2==0} {.t delete 3.0}
    update
    after 300
 }
 bind . <Escape> {exec wish $argv0 &; exit}
