tkwait visibility .
tk::toplevel .tk__toplevel334273280 -width "200" -height "200"
tkwait visibility .tk__toplevel334273280
wm geometry .tk__toplevel334273280
wm geometry .tk__toplevel334273280 200x200+500+500
update idletasks
ttk::treeview .tk__toplevel334273280.ttk__treeview334273281
.tk__toplevel334273280.ttk__treeview334273281 configure -columns "Filename Modified Created"
.tk__toplevel334273280.ttk__treeview334273281 heading #0 -text "Directory"
.tk__toplevel334273280.ttk__treeview334273281 heading 0 -text "Filename"
.tk__toplevel334273280.ttk__treeview334273281 heading 1 -text "Modified"
.tk__toplevel334273280.ttk__treeview334273281 heading 2 -text "Created"
.tk__toplevel334273280.ttk__treeview334273281 insert {} end -text "Root 1"
.tk__toplevel334273280.ttk__treeview334273281 insert I001 end -text "Child 1"
.tk__toplevel334273280.ttk__treeview334273281 insert I001 end -text "Child 2"
.tk__toplevel334273280.ttk__treeview334273281 insert I001 2 -text "Child 4"
.tk__toplevel334273280.ttk__treeview334273281 insert I001 2 -text "Child 3"
.tk__toplevel334273280.ttk__treeview334273281 insert I002 end -text "Child 1.1"
.tk__toplevel334273280.ttk__treeview334273281 insert I002 1 -text "Child 1.3"
.tk__toplevel334273280.ttk__treeview334273281 insert I002 1 -text "Child 1.2"
.tk__toplevel334273280.ttk__treeview334273281 children I002
.tk__toplevel334273280.ttk__treeview334273281 column #0 -id
.tk__toplevel334273280.ttk__treeview334273281 column #0 -anchor
.tk__toplevel334273280.ttk__treeview334273281 column #0 -minwidth
.tk__toplevel334273280.ttk__treeview334273281 column #0 -stretch
.tk__toplevel334273280.ttk__treeview334273281 column #0 -width

.tk__toplevel334273280.ttk__treeview334273281 column 0 -anchor e
.tk__toplevel334273280.ttk__treeview334273281 column 0 -minwidth 100
.tk__toplevel334273280.ttk__treeview334273281 column 0 -stretch 50
.tk__toplevel334273280.ttk__treeview334273281 column 0 -width 100

.tk__toplevel334273280.ttk__treeview334273281 column 0 -id
.tk__toplevel334273280.ttk__treeview334273281 column 0 -anchor
.tk__toplevel334273280.ttk__treeview334273281 column 0 -minwidth
.tk__toplevel334273280.ttk__treeview334273281 column 0 -stretch
.tk__toplevel334273280.ttk__treeview334273281 column 0 -width
.tk__toplevel334273280.ttk__treeview334273281 column 0 -id
.tk__toplevel334273280.ttk__treeview334273281 column 0 -anchor
.tk__toplevel334273280.ttk__treeview334273281 column 0 -minwidth
.tk__toplevel334273280.ttk__treeview334273281 column 0 -stretch
.tk__toplevel334273280.ttk__treeview334273281 column 0 -width

puts [.tk__toplevel334273280.ttk__treeview334273281 column 0 -minwidth]

pack .tk__toplevel334273280.ttk__treeview334273281
