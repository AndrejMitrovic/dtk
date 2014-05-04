package require Tk

# Todo: it uses ?? when the data is invalid, we should check for this like in the old Tk library.

#~ bind . <ButtonPress> {
    #~ puts "detail = %d"
#~ }

bind . <ButtonPress> { puts "Button press with: %s %K" }
#~ bind . <KeyPress> { puts "Key %s %K" }

#~ bind . <Control> { puts "Return" }
#~ bind . <Extended-Control> { puts "Right Return" }

#~ bind . <Return> { puts "Return" }
#~ bind . <Extended-Return> { puts "Right Return" }

#~ bind . <Alt-a> { puts "Alt - a" }
#~ bind . <Extended-Alt-a> { puts "Right Alt - a" }

#~ bind . <Return> {
    #~ puts "client_request = %#"
    #~ puts "win_below_target = %a"
    #~ puts "mouse_button = %b"
    #~ puts "count = %c"
    #~ puts "detail = %d"
    #~ puts "focus = %f"
    #~ puts "height = %h"
    #~ puts "win_hex_id = %i"
    #~ puts "keycode = %k"
    #~ puts "mode = %m"
    #~ puts "override_redirect = %o"
    #~ puts "place = %p"
    #~ puts "state = %s"
    #~ puts "timestamp = %t"
    #~ puts "width = %w"
    #~ puts "x_pos = %x"
    #~ puts "y_pos = %y"
    #~ puts "uni_char = %A"
    #~ puts "border_width = %B"
    #~ puts "mouse_wheel_delta = %D"
    #~ puts "send_event_type = %E"
    #~ puts "keysym_text = %K"
    #~ puts "keysym_decimal = %N"
    #~ puts "property_name = %P"
    #~ puts "root_window_id = %R"
    #~ puts "subwindow_id = %S"
    #~ puts "type = %T"
    #~ puts "window_id = %W"
    #~ puts "x_root = %X"
    #~ puts "y_root = %Y"
    #~ puts ""
#~ }
