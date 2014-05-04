
# Only need to escape \

puts [subst -nocommands -novariables {this is
a
long
string. I have $10 [10,000 cents] only backslash \\ and braces \{ needs \} to be escaped.
\t is not  a real tab, but '    ' is. "quoting somthing" :
\{matchin` curly braces are okay, list = string in tcl\}
}]
