# See http://wiki.tcl.tk/1425

proc set2entry { text } {
    global cursorName
    set cursorName $text
    .e selection range 0 end
 }

 proc main {} {

    global tcl_platform
    global cursorName

    set PAD 6; # extra space arount buttons
    set COLS 6; # number of button columns

    set CURSORS {
        {} X_cursor arrow based_arrow_down based_arrow_up boat bogosity bottom_left_corner
        bottom_right_corner bottom_side bottom_tee box_spiral center_ptr circle clock
        coffee_mug cross cross_reverse crosshair diamond_cross dot dotbox double_arrow
        draft_large draft_small draped_box exchange fleur gobbler gumby hand1 hand2
        heart icon iron_cross left_ptr left_side left_tee leftbutton ll_angle lr_angle
        man middlebutton mouse pencil pirate plus question_arrow right_ptr right_side
        right_tee rightbutton rtl_logo sailboat sb_down_arrow sb_h_double_arrow sb_left_arrow
        sb_right_arrow sb_up_arrow sb_v_double_arrow shuttle sizing spider spraycan
        star target tcross top_left_arrow top_left_corner top_right_corner top_side
        top_tee trek ul_angle umbrella ur_angle watch xterm
    }

    if { $tcl_platform(platform) == "windows" } {
        lappend CURSORS no starting size_ne_sw size_ns size_nw_se size_we uparrow wait
    }

    if { $tcl_platform(platform) == "macintosh" } {
        lappend CURSORS text cross-hair
    }

    grid [entry .e -textvar cursorName] -columnspan $COLS -sticky nswe

    foreach cursor $CURSORS {
        set w [button .w_$cursor -text $cursor -cursor $cursor -command "set2entry $cursor"]
        lappend ws $w
        if { [llength $ws] >= $COLS } {
            # place whole row of buttons
            eval grid $ws -ipadx $PAD -ipady $PAD -sticky nswe
            set ws {}
        }
    }
    if { [llength $ws] > 0 } {
        # place rest of buttons
        eval grid $ws -ipadx $PAD -ipady $PAD -sticky nswe
    }

 }

 main
