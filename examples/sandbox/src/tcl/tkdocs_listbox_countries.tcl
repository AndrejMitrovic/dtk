package require Tk

# Initialize our country "databases":
#  - the list of country codes (a subset anyway)
#  - a parallel list of country names, in the same order as the country codes
#  - a hash table mapping country code to population<
set countrycodes [list ar au be br ca cn dk fi fr gr in it jp mx nl no es se ch]
set countrynames [list Argentina Australia Belgium Brazil Canada China Denmark \
        Finland France Greece India Italy Japan Mexico Netherlands Norway Spain \
        Sweden Switzerland]
array set populations [list ar 41000000 au 21179211 be 10584534 br 185971537 \
        ca 33148682 cn 1323128240 dk 5457415 fi 5302000 fr 64102140 gr 11147000 \
        in 1131043000 it 59206382 jp 127718000 mx 106535000 nl 16402414 \
        no 4738085 es 45116894 se 9174082 ch 7508700]

# Names of the gifts we can send
array set gifts [list card "Greeting card" flowers "Flowers" nastygram "Nastygram"]

# Create and grid the outer content frame
grid [ttk::frame .c -padding "5 5 12 0"] -column 0 -row 0 -sticky nwes
grid columnconfigure . 0 -weight 1; grid rowconfigure . 0 -weight 1

# Create the different widgets; note the variables that many
# of them are bound to, as well as the button callback.
# The listbox is the only widget we'll need to refer to directly
# later in our program, so for convenience we'll assign it to a variable.
set ::lbox [tk::listbox .c.countries -listvariable countrynames -height 5]
ttk::label .c.lbl -text "Send to country's leader:"
ttk::radiobutton .c.g1 -text $gifts(card) -variable gift -value card
ttk::radiobutton .c.g2 -text $gifts(flowers) -variable gift -value flowers
ttk::radiobutton .c.g3 -text $gifts(nastygram) -variable gift -value nastygram
ttk::button .c.send -text "Send Gift" -command {sendGift} -default active
ttk::label .c.sentlbl -textvariable sentmsg -anchor center
ttk::label .c.status -textvariable statusmsg -anchor w

# Grid all the widgets
grid .c.countries -column 0 -row 0 -rowspan 6 -sticky nsew
grid .c.lbl       -column 1 -row 0 -padx 10 -pady 5
grid .c.g1        -column 1 -row 1 -sticky w -padx 20
grid .c.g2        -column 1 -row 2 -sticky w -padx 20
grid .c.g3        -column 1 -row 3 -sticky w -padx 20
grid .c.send      -column 2 -row 4 -sticky e
grid .c.sentlbl   -column 1 -row 5 -columnspan 2 -sticky n -pady 5 -padx 5
grid .c.status    -column 0 -row 6 -columnspan 2 -sticky we
grid columnconfigure .c  0 -weight 1; grid rowconfigure .c 5 -weight 1

# Set event bindings for when the selection in the listbox changes,
# when the user double clicks the list, and when they hit the Return key
bind $::lbox <<ListboxSelect>> "showPopulation"
bind $::lbox <Double-1> "sendGift"
bind . <Return> "sendGift"

# Called when the selection in the listbox changes; figure out
# which country is currently selected, and then lookup its country
# code, and from that, its population.  Update the status message
# with the new population.  As well, clear the message about the
# gift being sent, so it doesn't stick around after we start doing
# other things.
proc showPopulation {} {
    set idx [$::lbox curselection]
    if {[llength $idx]==1} {
        set code [lindex $::countrycodes $idx]
        set name [lindex $::countrynames $idx]
        set popn $::populations($code)
        set ::statusmsg "The population of $name ($code) is $popn"
    }
    set ::sentmsg ""
}

# Called when the user double clicks an item in the listbox, presses
# the "Send Gift" button, or presses the Return key.  In case the selected
# item is scrolled out of view, make sure it is visible.
#
# Figure out which country is selected, which gift is selected with the
# radiobuttons, "send the gift", and provide feedback that it was sent.
proc sendGift {} {
    set idx [$::lbox curselection]
    if {[llength $idx]==1} {
        $::lbox see $idx
        set name [lindex $::countrynames $idx]
        # Gift sending left as an exercise to the reader
        set ::sentmsg "Sent $::gifts($::gift) to leader of $name"
    }
}

# Colorize alternating lines of the listbox
for {set i 0} {$i<[llength $countrynames]} {incr i 2} {
    $::lbox itemconfigure $i -background #f0f0ff
}

# Set the starting state of the interface, including selecting the
# default gift to send, and clearing the messages.  Select the first
# country in the list; because the <<ListboxSelect>> event is only
# generated when the user makes a change, we explicitly call showPopulation.
set gift card
set sentmsg ""
set statusmsg ""
$::lbox selection set 0
showPopulation
