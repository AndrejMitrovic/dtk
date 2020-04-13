package require Tk
# corotcl --
#
#       A coroutine-enabled tclsh
#
package require Tk
proc lambda {params body args} {
    list ::apply [list $params $body] {*}$args
}
proc prompt p {
    puts -nonewline "$p "
    flush stdout
    fileevent stdin readable [lambda return {
        $return [gets stdin]
    } [info coroutine]]
    yield
}
proc get-command {} {
    set cmd [prompt %]
    while {![info complete $cmd]} {
        append cmd \n [prompt >]
    }
    return $cmd
}
proc repl {} {
    while 1 {
        set cmd [get-command]
        set code [catch { uplevel #0 $cmd } result opts]
        if {$code == 1} {
            puts [dict get $opts -errorinfo]
        } else { puts $result }
    }
}
coroutine main repl
#vwait forever ;# if no Tk
