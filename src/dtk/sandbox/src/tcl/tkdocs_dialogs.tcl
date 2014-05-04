package require Tk

after 1000 {
    # Send a space
    event generate {} <KeyPress> -keycode 32
}

set my_result [tk_messageBox -type "yesno" -message "Yes or No?"]
puts "res: $my_result"
