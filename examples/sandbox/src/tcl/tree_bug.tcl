package require Tk

ttk::treeview .tree
.tree insert {} end -id "id1" -text "text1"

# No bug, id has to come last
.tree insert {} end -text "text2" -id "id2"
