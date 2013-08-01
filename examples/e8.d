module e8;

import std.stdio;

import dtk;

int main(string[] args)
{
    auto root = new Tk();

    auto sb = new Spinbox(root);
    sb.pack();

    auto b = new Button(root, "Print",
                        (Widget w, Event)
                        {
                            writeln("get: ", sb.get());
                        });
    b.pack("side", "left");

    auto exitB = new Button(root, "Exit",
                            (Widget w, Event)
                            {
                                root.exit();
                            });
    exitB.pack("side", "left");

    root.mainloop();
    return 0;
}
