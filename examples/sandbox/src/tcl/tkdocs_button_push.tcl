package require Tk

pack [ttk::button .b -text hello -command "puts pressed"]

{.b state pressed}
{.b invoke}
after 300 {.b state !pressed}
