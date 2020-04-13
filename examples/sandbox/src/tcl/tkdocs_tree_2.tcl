package require Tk

wm title . "Text"

ttk::treeview .tree
.tree configure -columns "Filename Modified"
#~ .tree configure -columns "sizeID modifiedID ownerID"

#~ .tree column sizeID -width 100 -anchor center
.tree heading #0 -text "Directory"
.tree heading 0 -text "Filename"
.tree heading 1 -text "Modified"

.tree column 0 -stretch 50
puts [.tree column 0 -stretch]

pack .tree
