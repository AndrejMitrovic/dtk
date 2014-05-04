package require Tk

tkwait visibility .

focus .

bind . <Double-ButtonPress-1>    { puts "mouse double-press %b" }
event generate . <ButtonPress-1>
event generate . <ButtonRelease-1>
event generate . <ButtonPress-1>
event generate . <ButtonRelease-1>
