ttk::progressbar .progbar -variable ::var -mode indeterminate

proc tracer {varname args} {
    upvar #0 $varname var
    puts "var value: $var"

    # Note: call has no effect
    .progbar stop
}

trace add variable ::var write "tracer ::var"

.progbar start
pack .progbar
