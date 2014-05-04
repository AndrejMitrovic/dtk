package require Tk

#~ wm title . "Dialog"

#~ set my_result [tk_messageBox -type "yesno" -message "Are you sure you want to install SuperVirus?" -icon question -title "Install"]
#~ puts "res: $my_result"

set types {
    {{Text Files}       {.txt}        }
    {{TCL Scripts}      {.tcl}        }
    {{C Source Files}   {.c}      TEXT}
    {{GIF Files}        {.gif}        }
    {{GIF Files}        {}        GIFF}
    {{All Files}        *             }
}

#~ set filename [tk_getOpenFile -filetypes {{{Text Files} {.txt} }{{Tcl Scripts} {.tcl} }{{C Source Files} {.c} TEXT}}]

tk_getOpenFile -defaultextension "" -filetypes { { {Text Files}  {.txt}  } { {Tcl Scripts}  {.tcl}  } { {C Source Files}  {.c}  TEXT } } -initialdir "" -initialfile ""  -multiple false  -title "" -typevariable ::dtk_var2494336_0

#~ set filename [tk_getOpenFile -filetypes $types]

#~ if {$filename ne ""} {
puts $::dtk_var2494336_0
    # Open the file ...
#~ }
