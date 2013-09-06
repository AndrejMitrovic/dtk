package require Tk

bind dtk::intercept_tag <KeyPress> { puts "keyboard press %N %A %s %W %x %y %X %Y %t" }
bind dtk::intercept_tag <KeyRelease> { puts "keyboard release %N %A %s %W %x %y %X %Y %t" }
#~ bind dtk::intercept_tag <ButtonPress-1> { dtk::callback_handler mouse press button1 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Double-ButtonPress-1> { dtk::callback_handler mouse double_click button1 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Triple-ButtonPress-1> { dtk::callback_handler mouse triple_click button1 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Quadruple-ButtonPress-1> { dtk::callback_handler mouse quadruple_click button1 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <ButtonRelease-1> { dtk::callback_handler mouse release button1 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <ButtonPress-2> { dtk::callback_handler mouse press button2 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Double-ButtonPress-2> { dtk::callback_handler mouse double_click button2 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Triple-ButtonPress-2> { dtk::callback_handler mouse triple_click button2 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Quadruple-ButtonPress-2> { dtk::callback_handler mouse quadruple_click button2 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <ButtonRelease-2> { dtk::callback_handler mouse release button2 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <ButtonPress-3> { dtk::callback_handler mouse press button3 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Double-ButtonPress-3> { dtk::callback_handler mouse double_click button3 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Triple-ButtonPress-3> { dtk::callback_handler mouse triple_click button3 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Quadruple-ButtonPress-3> { dtk::callback_handler mouse quadruple_click button3 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <ButtonRelease-3> { dtk::callback_handler mouse release button3 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <ButtonPress-4> { dtk::callback_handler mouse press button4 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Double-ButtonPress-4> { dtk::callback_handler mouse double_click button4 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Triple-ButtonPress-4> { dtk::callback_handler mouse triple_click button4 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Quadruple-ButtonPress-4> { dtk::callback_handler mouse quadruple_click button4 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <ButtonRelease-4> { dtk::callback_handler mouse release button4 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <ButtonPress-5> { dtk::callback_handler mouse press button5 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Double-ButtonPress-5> { dtk::callback_handler mouse double_click button5 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Triple-ButtonPress-5> { dtk::callback_handler mouse triple_click button5 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Quadruple-ButtonPress-5> { dtk::callback_handler mouse quadruple_click button5 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <ButtonRelease-5> { dtk::callback_handler mouse release button5 %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <Motion> { dtk::callback_handler mouse motion %b %D %s %W %x %y %X %Y %t }
#~ bind dtk::intercept_tag <MouseWheel> { dtk::callback_handler mouse wheel %b %D %s %W %x %y %X %Y %t }

bindtags . [list dtk::intercept_tag Toplevel . all ]
tkwait visibility .

tk::toplevel .tk__toplevel72784640
bindtags .tk__toplevel72784640 [list dtk::intercept_tag Toplevel .tk__toplevel72784640 all ]
tkwait visibility .tk__toplevel72784640

event generate .tk__toplevel72784640 <KeyPress> -keysym a
