module e1;

import std.stdio;

import dtk;

int main(string[] args)
{
    auto root = new Tk();

    auto label = new Label(root, "hello world!");
    label.pack();
    auto msg = new Message(root, "Wellcome to\ndkinter!");
    msg.pack();

    root.mainloop();
    return 0;
}
