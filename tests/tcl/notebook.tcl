tkwait visibility .

ttk::notebook .note

ttk::frame .note.f0
ttk::frame .note.f1
.note add .note.f0
.note add .note.f1

pack .note

puts [.note index .note.f1]; # Prints 1
puts [.note index 1]; # How do I get the widget path of index 1?
