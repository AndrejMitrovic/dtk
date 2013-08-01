module e6;

import std.stdio;

import dtk;

int main(string[] args)
{
    auto root = new Tk();

    auto scale = new Scale(root, "scale");
    scale.pack();
    scale.cfg(["orient" : HORIZONTAL]);
    auto scaleButton = new Button(root, "Print",
                                  (Widget w, Event)
                                  {
                                      writeln("get: ", scale.get());
                                      scale.set(10);
                                  });
    scaleButton.pack();
    auto button = new Button(root, "Exit",
                             (Widget w, Event)
                             {
                                 root.exit();
                             });
    button.pack();
    root.mainloop();
    return 0;
}
