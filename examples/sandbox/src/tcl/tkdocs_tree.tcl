package require Tk

wm title . "Text"

ttk::treeview .tree

# Inserted at the root, user chooses id:
.tree insert {} end -id widgets -text "Widget Tour"

# Same thing, but inserted as first child:
.tree insert {} 0 -id gallery -text "Applications"

# Treeview chooses the id:
set tutorID [.tree insert {} end -id tutorIdent -text "Tutorial"]

# Inserted underneath an existing node:
set canvasID [.tree insert widgets end -id canvasIDa -text "Canvas"]

set tree1ID [.tree insert $tutorID end -id tree1 -text "Tree"]
set tree2ID [.tree insert $tutorID end -id tree2 -text "Tree2"]

#~ .tree move widgets {} end; # move widgets last in root

#~ .tree detach widgets; # does not destroy

#~ .tree move widgets {} end; # put back in

#~ # .tree delete widgets; # actually destroy
#~ # at this point it can't be added back
#~ # .tree move widgets {} end;

#~ .tree item widgets -open true
#~ set isopen [.tree item widgets -open]

#~ puts [.tree parent widgets]; # should print empty string

#~ puts [.tree parent $canvasID]; # should print 'widgets'
#~ puts [.tree next $tutorID ]; # should print 'widgets'

puts [.tree next $tree1ID ]; # should print 'tree2' (because we set the ID explicitly)
puts [.tree prev $tree2ID ]; # should print 'tree1' (ditto)
puts [.tree parent $tree1ID ]; # should print 'tutorIdent' (ditto)
puts [.tree children $tutorID]; # should print 'tree1 tree2' (ditto)

pack .tree
