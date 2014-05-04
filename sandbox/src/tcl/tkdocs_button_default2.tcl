package require Tk

tk_dialog .dg "Title" "Question" "" "" \
[ttk::button .button1 -text "Yes" -default disabled] \
[ttk::button .button2 -text "No" -default active]
