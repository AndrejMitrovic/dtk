module e2;

import std.stdio;

import dtk;

int main(string[] args)
{
    auto root = new Tk();

    auto label = new Label(root, "Hello!");
    label.cfg(["bg" : "black", "fg" : "green"]);
    label.pack();

    auto button = new Button(root, "OK",
                             (Widget w, Event e)
                             {
                                 root.exit();
                             });
    button.pack();
    root.mainloop();
    return 0;
}
