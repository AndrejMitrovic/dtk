ttk::progressbar .prog1
grid .prog1 -row 0 -column 0

# Get or set options
puts [ttk::style configure TButton]

# Get a specific option
puts [ttk::style lookup TButton -relief]

puts [ttk::style layout TButton]
