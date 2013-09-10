package require Tk

font create mainFont   {*}[font configure TkDefaultFont]
set font mainFont

set w .ttkpane
catch {destroy $w}
toplevel $w
wm geometry $w 800x400+300+300

wm iconify .

bind $w <Destroy> { destroy . }

wm title $w "Themed Nested Panes"

ttk::frame $w.f
pack $w.f -fill both -expand 1
set w $w.f
ttk::panedwindow $w.outer -orient horizontal
$w.outer add [ttk::panedwindow $w.outer.inLeft -orient vertical]
$w.outer add [ttk::panedwindow $w.outer.inRight -orient vertical]
$w.outer.inLeft  add [ttk::labelframe $w.outer.inLeft.top  -text Button]
$w.outer.inLeft  add [ttk::labelframe $w.outer.inLeft.bot  -text Clocks]
$w.outer.inRight add [ttk::labelframe $w.outer.inRight.top -text Progress]
$w.outer.inRight add [ttk::labelframe $w.outer.inRight.bot -text Text]

# Fill the clocks pane
set i 0
set testzones {
    :Europe/Berlin
    :America/Argentina/Buenos_Aires
    :Africa/Johannesburg
    :Europe/London
    :America/Los_Angeles
    :Europe/Moscow
    :America/New_York
    :Asia/Singapore
    :Australia/Sydney
    :Asia/Tokyo
}
# Force a pre-load of all the timezones needed; otherwise can end up
# poor-looking synch problems!
set zones {}
foreach zone $testzones {
    if {![catch {clock format 0 -timezone $zone}]} {
        lappend zones $zone
    }
}
if {[llength $zones] < 2} { lappend zones -0200 :GMT :UTC +0200 }
foreach zone $zones {
    set city [string map {_ " "} [regexp -inline {[^/]+$} $zone]]
    if {$i} {
	pack [ttk::separator $w.outer.inLeft.bot.s$i] -fill x
    }
    ttk::label $w.outer.inLeft.bot.l$i -text $city -anchor w
    ttk::label $w.outer.inLeft.bot.t$i -textvariable time($zone) -anchor w
    pack $w.outer.inLeft.bot.l$i $w.outer.inLeft.bot.t$i -fill x
    incr i
}

# Fill the progress pane
ttk::progressbar $w.outer.inRight.top.progress -mode indeterminate
pack $w.outer.inRight.top.progress -fill both -expand 1
#~ $w.outer.inRight.top.progress start

# Fill the text pane
# The trick with the ttk::frame makes the text widget look like it fits with
# the current Ttk theme despite not being a themed widget itself. It is done
# by styling the frame like an entry, turning off the border in the text
# widget, and putting the text widget in the frame with enough space to allow
# the surrounding border to show through (2 pixels seems to be enough).
ttk::frame $w.outer.inRight.bot.f				-style TEntry
text $w.txt -wrap word -yscroll "$w.sb set" -width 30	-borderwidth 0
pack $w.txt -fill both -expand 1 -in $w.outer.inRight.bot.f	-pady 2 -padx 2
ttk::scrollbar $w.sb -orient vertical -command "$w.txt yview"
pack $w.sb -side right -fill y -in $w.outer.inRight.bot
pack $w.outer.inRight.bot.f -fill both -expand 1
pack $w.outer -fill both -expand 1
