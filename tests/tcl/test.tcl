ttk::notebook .c.note
ttk::frame .c.note.f1; # first page, which would get widgets gridded into it
ttk::frame .c.note.f2; # second page
.c.note add .c.note.f1 -text "One"
.c.note add .c.note.f2 -text "Two"
