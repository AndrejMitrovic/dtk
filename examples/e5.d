module e5;

import std.stdio;

import dtk;

int main(string[] args)
{
    auto root = new Tk();

    auto radioButton = new Radiobutton(root, "Radio", 0);
    radioButton.pack();
    auto button1 = new Button(root, "Flash",
                              (Widget w, Event)
                              {
                                  radioButton.flash();
                              });
    button1.pack();
    auto button2 = new Button(root, "Deselect",
                              (Widget w, Event)
                              {
                                  radioButton.deselect();
                              });
    button2.pack();
    auto button3 = new Button(root, "Select",
                              (Widget w, Event)
                              {
                                  radioButton.select();
                              });
    button3.pack();
    root.mainloop();
    return 0;
}
