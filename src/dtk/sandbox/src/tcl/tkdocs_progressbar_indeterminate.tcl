package require Tk

#~ wm title . "Progressbar"

#~ ttk::progressbar .bar -orient horizontal -length 200 -mode determinate

#~ pack .bar

ttk::progressbar .ttk__progressbar62298880 -orient "horizontal" -maximum "100" -length "200" -mode "indeterminate"
pack .ttk__progressbar62298880
.ttk__progressbar62298880 configure -value "50"
.ttk__progressbar62298880 start
.ttk__progressbar62298880 stop
