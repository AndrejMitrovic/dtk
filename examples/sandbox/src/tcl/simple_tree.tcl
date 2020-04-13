package require Tk
ttk::treeview .tree
.tree configure -columns "one two"
.tree heading #0 -text "left"
.tree heading 0 -text "right"
pack .tree

.tree configure -show tree
.tree insert {} end -id widgets -text "Widget Tour"

.tree set widgets 0 "First Value"
