package require Tk

wm title . "Feet to Meters"
grid [ttk::frame .foo -padding "3 3 12 12"] -column 0 -row 0 -sticky nwes
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

grid [ttk::entry .foo.feet -width 7 -textvariable feet] -column 2 -row 1 -sticky we
grid [ttk::label .foo.meters -textvariable meters] -column 2 -row 2 -sticky we
grid [ttk::button .foo.calc -text "Calculate" -command calculate] -column 3 -row 3 -sticky w

grid [ttk::label .foo.flbl -text "feet"] -column 3 -row 1 -sticky w
grid [ttk::label .foo.islbl -text "is equivalent to"] -column 1 -row 2 -sticky e
grid [ttk::label .foo.mlbl -text "meters"] -column 3 -row 2 -sticky w

foreach w [winfo children .foo] {grid configure $w -padx 5 -pady 5}
focus .foo.feet
bind . <Return> {calculate}

proc calculate {} {
   if {[catch {
       set ::meters [expr {round($::feet*0.3048*10000.0)/10000.0}]
   }]!=0} {
       set ::meters ""
   }
}
