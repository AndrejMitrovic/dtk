package require Tk

#~ Can invoke method when a variable is updated, we could use this for D callbacks
proc varlimit_re {re var key op} {
  upvar $var v
  if { [regexp -- $re $v] <= 0 } {
    error "$var out of range"
  }
}

trace add variable ::myvar {write} [list varlimit_re {^[A-H]\d{3}-[0-9a-f]+$}]`
