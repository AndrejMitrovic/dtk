set frq [list a b c d e f]

puts $frq
set frq [lreplace $frq 2 2 x]

puts $frq

lset frq 2 y

puts $frq
