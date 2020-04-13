ttk::panedwindow .p -orient vertical
# first pane, which would get widgets gridded into it:
ttk::labelframe .p.f1 -text Pane1 -width 100 -height 100
ttk::labelframe .p.f2 -text Pane2 -width 100 -height 100; # second pane
.p add .p.f1
.p add .p.f2

pack .p
