proc initForCaps {} {
    global switchState
    .edit_button configure -text Caps -command { set Entry [string toupper $Entry] }
    set switchState initForSmall
}

proc initForSmall {} {
    global switchState
    .edit_button configure -text Small -command { set Entry [string tolower $Entry] }
    set switchState initForCaps
}

#~ proc quit {} {
    #~ global Entry switchState
    #~ destroy .entry .edit_button .quit_button
    #~ unset Entry switchState
    #~ bind . <Key-Tab> {}
#~ }

entry .entry -textvariable Entry
pack .entry

button .edit_button
pack .edit_button

#~ button .quit_button -text Quit -command { quit }
#~ pack .quit_button

initForCaps
bind . <Key-Tab> { $switchState; break }
