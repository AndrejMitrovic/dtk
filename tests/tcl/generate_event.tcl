package require Tk

toplevel .toplevel

tkwait visibility .toplevel

bind .toplevel <ButtonPress>   { puts "Press: %D %s %W %x %y %X %Y %t" }
bind .toplevel <ButtonRelease> { puts "Release: %D %s %W %x %y %X %Y %t" }

event generate .toplevel <ButtonPress> -button 1 -state 0
event generate .toplevel <ButtonPress> -button 1 -state 0
event generate .toplevel <ButtonPress> -button 1 -state 0

#~ event generate .tk__toplevel72784640 <ButtonPress> -button 1 -state 0

#~ bind . <Double-ButtonPress-1>    { puts "mouse press   release         button1 %s %W %t" }
#~ bind . <Triple-ButtonPress-1>    { puts "mouse press   triple_click    button1 %s %W %t" }
#~ bind . <Quadruple-ButtonPress-1> { puts "mouse press   quadruple_click button1 %s %W %t" }
#~ bind . <ButtonRelease-1>         { puts "mouse release                 button1 %s %W %t" }
#~ bind . <ButtonPress-2>           { puts "mouse press   press           button2 %s %W %t" }
#~ bind . <Double-ButtonPress-2>    { puts "mouse press   release         button2 %s %W %t" }
#~ bind . <Triple-ButtonPress-2>    { puts "mouse press   triple_click    button2 %s %W %t" }
#~ bind . <Quadruple-ButtonPress-2> { puts "mouse press   quadruple_click button2 %s %W %t" }
#~ bind . <ButtonRelease-2>         { puts "mouse release                 button2 %s %W %t" }
#~ bind . <ButtonPress-3>           { puts "mouse press   press           button3 %s %W %t" }
#~ bind . <Double-ButtonPress-3>    { puts "mouse press   release         button3 %s %W %t" }
#~ bind . <Triple-ButtonPress-3>    { puts "mouse press   triple_click    button3 %s %W %t" }
#~ bind . <Quadruple-ButtonPress-3> { puts "mouse press   quadruple_click button3 %s %W %t" }
#~ bind . <ButtonRelease-3>         { puts "mouse release                 button3 %s %W %t" }
#~ bind . <ButtonPress-4>           { puts "mouse press   press           button4 %s %W %t" }
#~ bind . <Double-ButtonPress-4>    { puts "mouse press   release         button4 %s %W %t" }
#~ bind . <Triple-ButtonPress-4>    { puts "mouse press   triple_click    button4 %s %W %t" }
#~ bind . <Quadruple-ButtonPress-4> { puts "mouse press   quadruple_click button4 %s %W %t" }
#~ bind . <ButtonRelease-4>         { puts "mouse release                 button4 %s %W %t" }
#~ bind . <ButtonPress-5>           { puts "mouse press   press           button5 %s %W %t" }
#~ bind . <Double-ButtonPress-5>    { puts "mouse press   release         button5 %s %W %t" }
#~ bind . <Triple-ButtonPress-5>    { puts "mouse press   triple_click    button5 %s %W %t" }
#~ bind . <Quadruple-ButtonPress-5> { puts "mouse press   quadruple_click button5 %s %W %t" }
#~ bind . <ButtonRelease-5>         { puts "mouse release                 button5 %s %W %t" }
#~ bind . <Motion>                  { puts "mouse motion                  mouse_button %s %W %t" }
#~ bind . <MouseWheel>              { puts "mouse wheel                   mouse_wheel_delta %b %D %s %W %x %y %X %Y %t" }

#~ tcl_eval: bind dtk::intercept_tag <KeyPress> { dtk::callback_handler keyboard press %N %A %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <KeyRelease> { dtk::callback_handler keyboard release %N %A %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <ButtonPress-1> { dtk::callback_handler mouse press button1 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Double-ButtonPress-1> { dtk::callback_handler mouse release button1 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Triple-ButtonPress-1> { dtk::callback_handler mouse triple_click button1 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Quadruple-ButtonPress-1> { dtk::callback_handler mouse quadruple_click button1 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <ButtonRelease-1> { dtk::callback_handler mouse release button1 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <ButtonPress-2> { dtk::callback_handler mouse press button2 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Double-ButtonPress-2> { dtk::callback_handler mouse release button2 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Triple-ButtonPress-2> { dtk::callback_handler mouse triple_click button2 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Quadruple-ButtonPress-2> { dtk::callback_handler mouse quadruple_click button2 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <ButtonRelease-2> { dtk::callback_handler mouse release button2 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <ButtonPress-3> { dtk::callback_handler mouse press button3 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Double-ButtonPress-3> { dtk::callback_handler mouse release button3 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Triple-ButtonPress-3> { dtk::callback_handler mouse triple_click button3 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Quadruple-ButtonPress-3> { dtk::callback_handler mouse quadruple_click button3 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <ButtonRelease-3> { dtk::callback_handler mouse release button3 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <ButtonPress-4> { dtk::callback_handler mouse press button4 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Double-ButtonPress-4> { dtk::callback_handler mouse release button4 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Triple-ButtonPress-4> { dtk::callback_handler mouse triple_click button4 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Quadruple-ButtonPress-4> { dtk::callback_handler mouse quadruple_click button4 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <ButtonRelease-4> { dtk::callback_handler mouse release button4 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <ButtonPress-5> { dtk::callback_handler mouse press button5 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Double-ButtonPress-5> { dtk::callback_handler mouse release button5 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Triple-ButtonPress-5> { dtk::callback_handler mouse triple_click button5 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Quadruple-ButtonPress-5> { dtk::callback_handler mouse quadruple_click button5 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <ButtonRelease-5> { dtk::callback_handler mouse release button5 %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <Motion> { dtk::callback_handler mouse motion %b %D %s %W %x %y %X %Y %t } -- result:
#~ tcl_eval: bind dtk::intercept_tag <MouseWheel> { dtk::callback_handler mouse wheel %b %D %s %W %x %y %X %Y %t } -- result:
