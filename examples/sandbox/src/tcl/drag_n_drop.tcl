# See http://wiki.tcl.tk/571

# Purpose : to process the dropped element inside the target widget
proc place_listbox_proccess_DAD {args} {
  global DAD_content
  [lindex $args 0] insert end $DAD_content
}

# Purpose       : enables Drag-And-Drop controls of any listbox widget
proc place_listbox_controls_DAD {w {cutOrig 0} {procName "place_listbox_proccess_DAD"}} {
  bind $w <ButtonPress-1> {+;
    set DAD_pressed 1
  }

  bind $w <Motion> {+;
    if {[catch {set DAD_pressed $DAD_pressed}]} {set DAD_pressed 0}
    if {$DAD_pressed} {
      %W config -cursor exchange
      if {[catch {set DAD_content [%W get [%W curselection]]}]} {
        set DAD_pressed 0
      }
    } else {
      %W config -cursor ""
    }
  }

  if $cutOrig {set cutCmd "$w delete \[$w curselection\]"} else {set cutCmd ""}
  if {$procName == ""} {set procName place_listbox_proccess_DAD}

  set cmd "bind $w \<ButtonRelease-1\> \{+\;
    $w config -cursor \"\"
    set DAD_pressed 0
    if \{\[catch \{set DAD_content \$DAD_content\}\]\} \{set DAD_content \"\"\}
    if \{\$DAD_content != \"\"\} \{
      set wDAD   \[winfo containing  \[winfo pointerx .\]  \[winfo pointery .\]\]
      if \{\(\$wDAD ne \"\"\) && \(\$wDAD != \"\%W\"\)\} \{
        if !\[catch \{$procName \$wDAD\}\] \{$cutCmd\}
      \}
      set DAD_content \"\"
    \}
  \}"
  eval $cmd
}

# ---------- TEST CODE ------------------------
listbox .ls1 -height 20 -width 10
foreach item {a b c d e} {.ls1 insert end $item}
listbox .ls2 -height 20 -width 10
foreach item {f g h i j} {.ls2 insert end $item}
place .ls1 -x 10 -y 50
place .ls2 -x 100 -y 50

place_listbox_controls_DAD .ls1
place_listbox_controls_DAD .ls2 1
