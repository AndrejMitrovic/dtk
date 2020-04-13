bind InterceptEvent <Button-1> {
    puts %t
}

event generate InterceptEvent <Button-1>
