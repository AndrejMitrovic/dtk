package require Tk

wm title . "Feet to Meters"

# Sticky means within the grid cell (not the parent widget) which sides to stick to
# (e.g. stick to top-left corner when 'nw' is set, or to the sides if 'ew' is set)
# nwes means stick to all sides
grid [ttk::frame .frame -padding "3 3 12 12"] -column 0 -row 0 -sticky nwes

grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

grid [ttk::entry .frame.feet -width 7 -textvariable feet] -column 1 -row 0 -sticky we
grid [ttk::label .frame.meters -textvariable meters] -column 1 -row 1 -sticky we
grid [ttk::button .frame.calc -text "Calculate" -command calculate] -column 2 -row 2 -sticky w

set ::meters 0.0

# These are the labels
grid [ttk::label .frame.flbl -text "feet"] -column 2 -row 0 -sticky w
grid [ttk::label .frame.islbl -text "is equivalent to"] -column 0 -row 1 -sticky e
grid [ttk::label .frame.mlbl -text "meters"] -column 2 -row 1 -sticky w

foreach w [winfo children .frame] {grid configure $w -padx 5 -pady 5}

focus .frame.feet
bind . <Return> {calculate}

proc calculate {} {
   if {[catch {
       set ::meters [expr {round($::feet*0.3048*10000.0)/10000.0}]
   }]!=0} {
       set ::meters 0.0
   }
}
