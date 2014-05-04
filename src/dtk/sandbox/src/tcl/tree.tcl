package require Tk

wm title . "Text"

ttk::treeview .tree

# Inserted at the root, user chooses id:
.tree insert {} end -id widgets -text "Widget Tour"

#~ .tree column 0 minwidth

pack .tree
