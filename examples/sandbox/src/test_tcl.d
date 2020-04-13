module tcl;

/**
    Various tests with calling the Tcl interpreter.
*/

import std.stdio;
import std.range;

import dtk;

void print(string input)
{
    stderr.writefln(" res: %s", input);
}

void main()
{
    auto app = new App();
    //~ app.eval("ttk::style element names").print;
    //~ app.eval("ttk::style element options thumb").print;
    //~ app.eval("ttk::style theme names").print;
    //~ app.eval("ttk::style theme use clam").print;

    //~ auto button1 = new Button(app, "Flash");
    //~ button1.pack();

    //~ app.run();

    //~ % wish8.5
    // create a button, passing two options:
    app.eval(`grid [ttk::button .b -text "Hello" -command {button_pressed}]`).print;

    // check the current value of the text option:
    app.eval(`.b cget -text`).print;

    // check the current value of the command option:
    app.eval(`.b cget -command`).print;

    // change the value of the text option:
    app.eval(`.b configure -text Goodbye`).print;

    // check the current value of the text option:
    app.eval(`.b cget -text`).print;

    // get all information about the text option:
    app.eval(`.b configure -text`).print;

    // get information on all options for this widget:
    app.eval(`.b configure`).print;
}
