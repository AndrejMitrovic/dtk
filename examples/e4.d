module e4;

import std.stdio;
import std.string;
import std.conv;

import dtk;

int main(string[] args)
{
    auto root = new Tk();
    auto listBox = new Listbox(root);
    listBox.insert(0, ["1", "2", "3", "4", "5"]);
    listBox.pack();

    auto button1 = new Button(root, "Pop",
                              (Widget w, Event)
                              {
                                  listBox.del(0, 0);
                              }
                              );
    button1.pack();
    auto button2 = new Button(root, "Push",
                              (Widget w, Event)
                              {
                                  static int next = 10;
                                  listBox.insert(listBox.size(), [to!string(next++)]);
                              }
                              );
    button2.pack();

    auto button3 = new Button(root, "Selected",
                              (Widget w, Event)
                              {
                                  writeln("index> ",
                                          listBox.curselection(),
                                          " value> ",
                                          listBox.get(listBox.curselection()));
                              });
    button3.pack();
    root.mainloop();
    return 0;
}
