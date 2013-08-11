package require Tk

ttk::entry .ttk::entry47880960

set ::dtk_var4788096_1 true

proc validate_dtk_call4788096_3 {args} {
    #~ dtk::call4788096_1 args
    return $::dtk_var4788096_1

    #~ return true
}

.ttk::entry47880960 configure -validate "key"
.ttk::entry47880960 configure -validatecommand "validate_dtk_call4788096_3 TkValidate %d %i %P %s %S %v %V %W"

#~ ttk::entry .name -textvariable username
pack .ttk::entry47880960
