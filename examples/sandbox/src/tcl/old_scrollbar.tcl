toplevel .tl
ttk::frame .tl.fr
.tl.fr configure -xscrollcommand {.tl.s set}
scrollbar .tl.s -command {.tl.t yview}
grid .tl.t .tl.s -sticky nsew
grid columnconfigure .tl 0 -weight 1
grid rowconfigure .tl 0 -weight 1
