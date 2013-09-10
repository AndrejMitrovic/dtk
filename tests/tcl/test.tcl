set var1 5
set var2 3
#~ set var3 = $var1 - $var2; # error line

#~ puts $var3

set var3 [expr {$var1 - $var2}]
puts $var3

set newDiff [::tcl::mathfunc::max $var3 100]
puts $newDiff
