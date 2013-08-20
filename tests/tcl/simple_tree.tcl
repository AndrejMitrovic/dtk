package require Tk
ttk::treeview .tree
.tree configure -columns "right"
.tree heading #0 -text "left"
.tree heading 0 -text "right"
pack .tree
