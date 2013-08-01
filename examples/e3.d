module e3;

import std.stdio;

import dtk;

int main(string[] args)
{
    auto root = new Tk();

    auto entry = new Entry(root);
    entry.pack();
    auto button = new Button(root, "OK",
                             (Widget w, Event)
                             {
                                 writeln(entry.text());
                                 entry.text("Hello, user! :)");
                             });
    button.pack();

    // see event types in http://www.astro.princeton.edu/~rhl/Tcl-Tk_docs/tk/bind.n.html
    //~ entry.bind("<Button-1>",
    entry.bind("<Motion>",
               (Widget, Event ev)
               {
                   writeln("Clicked!!!");
                   writeln("x=", ev.x, " y=", ev.y);
               });

    root.mainloop();
    return 0;
}
