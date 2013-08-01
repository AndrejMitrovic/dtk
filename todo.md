Public Tcl interfaces are in:
    tclDecls.h
    tclPlatDecls.h
and Tk:
    tkDecls.h
    tkPlatDecls.h
Or just search for "public Tcl API" in scite.

Tcl/Tk Wish Syntax:
http://docstore.mik.ua/orelly/linux/run/ch13_05.htm

There are Tcl_LinkVar and Tcl_UpdateLinkedVar, which enables TCL variables to C and vice-versa. 
Might be useful (e.g. if some internal Tcl state changes we might want our own fields to change as well,
instead of invoking some getter method into Tcl to check the state of some variable).

todo:
Replace TTK's awful input boxes with Windows-standard input boxes.

todo:
We could autogenerate the entire bindings, everything is used via eval() and
the new ttk widgets are easily instantiated via e.g. ttk::button compared to button.

Todo first:
There are multiple eval methods, we could try using more efficient ones:
http://www.tcl.tk/man/tcl/TclLib/Eval.htm
http://wiki.tcl.tk/5925
Basically we could use a Tcl_Obj[] cmd; or something similar.

Todo1:
Replace string appends everywhere (e.g. pure_eval("tkButtonEnter " ~ m_name);)
with a refresh function which recreates an existing table of strings. Maybe
make it a char[1024][NumOfMethods], and also null all positions beyond the length
of the minimum and maximum valid char. Here's the explanation:

char[1024][NumOfMethods] fields;  // init all with 0 initially
// must be length NumOfMethods, or better we could set fields to be count of Names
enum Names { tkButtonEnter, tkButtonDown }
void tkButtonEnter()
{
    pure_eval(fields[Names.tkButtonEnter].ptr)
}

void tkButtonLeave()
{
    pure_eval(fields[Names.tkButtonLeave].ptr)
}

void onChange(strint newName) 
{
    foreach (i, methodName; methodNames)
    {
        // only zero the name field
        fields[i][methodName.count .. methodName.count + oldName.count] = 0;
        fields[i][methodName.count .. methodName.count + newName.count] = newName[];
    }
}

NOTE: Make a good test-case before performing these optimizations. A test-case with lots of
widget additions, changing settings, etc, and check for memory allocations in GC 
(we should build Druntime with that Debug flag), and also via procexp.exe). We could also
check another app to use for a memory view of things.

Todo2:
Figure out if eval() requires us to keep a reference to the strings, or if we can discard
them. If references are not needed, then we can make calls in canvas and other classes
faster, currently a lot of appending takes place:
    return eval("create text " ~ spaceJoin([x, y]) ~ " -text \"" ~ txt ~ "\" -fill " ~ color);
spaceJoin might be harder to implement without GC allocations.


and then do some performance benchmarks.

Configs are done via hashes, but built-in hashes might be too slow to construct.
See about using dcollections and using something like a config type, e.g.
config["bla"] = "config, config"
