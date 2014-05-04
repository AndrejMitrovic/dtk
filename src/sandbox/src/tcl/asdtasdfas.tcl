package require Tk

after 1000 {
    # Generate a space key for the entire desktop
    event generate "" <KeyPress> -keycode 32
}

set my_result [tk_messageBox -type "yesno" -message "Yes or No?"]
puts "res: $my_result"
