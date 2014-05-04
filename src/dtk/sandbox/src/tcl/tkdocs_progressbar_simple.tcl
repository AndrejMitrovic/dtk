package require Tk

#~ wm title . "Progressbar"

#~ ttk::progressbar .bar -orient horizontal -length 200 -mode determinate

#~ pack .bar

ttk::progressbar .ttk__progressbar62298880 -orient "horizontal" -maximum "100" -length "200" -mode "determinate"
pack .ttk__progressbar62298880
puts [.ttk__progressbar62298880 cget -value]
