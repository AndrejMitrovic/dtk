module button;

import std.stdio;

import dtk;

void main()
{
    auto root = new Tk();

    Button button1;
    button1 = new Button(root, "Flash", (Widget, Event) { });
    button1.pack();

    button1.underline = 2;
    assert(button1.underline == 2);

    root.mainloop();
}
