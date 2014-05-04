package require Tk

ttk::entry .e
pack .e

.e insert 0 "foobar"
.e selection range 0 end
