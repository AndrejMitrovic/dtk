package require Tk 8.5

proc tearoff {w b} {
    grid remove $w
    grid remove $b
    wm manage $w
    wm protocol $w WM_DELETE_WINDOW [list untearoff $w $b]
}

proc untearoff {w b} {
    wm forget $w
    grid $b -sticky nsew
    grid $w
}

frame .myframe
button .myframe.button -command { tearoff .myframe .myframe.button } -text "Undock"
grid .myframe -sticky news
grid .myframe.button -sticky news
