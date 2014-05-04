package require Tk 8.5

proc undock {buttonWidget frameWidget} {
    wm manage $frameWidget
    $buttonWidget configure -command { dock .myframe.button .myframe } -text "Dock"
}

proc dock {buttonWidget frameWidget} {
    wm forget $frameWidget
    grid $frameWidget -sticky news
    $buttonWidget configure -command { undock .myframe.button .myframe } -text "Undock"
    grid .myframe.button -sticky news
}

frame .myframe
button .myframe.button -command { undock .myframe.button .myframe } -text "Undock"
grid .myframe -sticky news
grid .myframe.button -sticky news

