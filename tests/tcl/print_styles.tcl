package require Tk

proc print_it {name style} {
    $style .$name
    puts [.$name cget -style]
    puts [winfo class .$name]
}

print_it "a" "ttk::button"
print_it "b" "ttk::checkbutton"
print_it "c" "ttk::combobox"
print_it "d" "ttk::entry"
print_it "e" "ttk::frame"
print_it "f" "ttk::label"
print_it "g" "ttk::labelframe"
print_it "h" "ttk::menubutton"
print_it "i" "ttk::notebook"
print_it "j" "ttk::panedwindow"
print_it "k" "ttk::progressbar"
print_it "l" "ttk::radiobutton"
print_it "m" "ttk::scale"
print_it "n" "ttk::scrollbar"
print_it "o" "ttk::separator"
print_it "p" "ttk::sizegrip"
print_it "q" "ttk::spinbox"
print_it "r" "ttk::treeview"
