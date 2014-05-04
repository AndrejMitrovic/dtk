module tcl;

/**
    Various tests with calling the Tcl interpreter.
*/

import std.conv;
import std.stdio;
import std.string;
import std.range;

import dtk;

void print(string input)
{
    stderr.writefln(" res: %s", input);
}

extern(C)
int dtkCallbackHandler(ClientData clientData, Tcl_Interp* interp, int objc, const Tcl_Obj** objv)
{
    string a = to!string(Tcl_GetString(objv[1]));
    string b = to!string(Tcl_GetString(objv[2]));

    stderr.writefln("objv[1] = %s", a);  // updated_var
    stderr.writefln("objv[2] = %s", b);  // foo

    return TCL_OK;
}

extern(C)
void dtkCallbackDeleter(ClientData clientData)
{
}

void main()
{
    auto app = new App();

    string varName = "::my_var";
    string procName = "my_tracer";

    enum _dtkCallbackIdent = "my_c_callback";

    Tcl_CreateObjCommand(App._interp,
                         cast(char*)_dtkCallbackIdent.toStringz,
                         &dtkCallbackHandler,
                         null,  // no extra client data
                         &dtkCallbackDeleter);


    app.evalFmt(`
        proc %s {varname args} {
            upvar #0 $varname var
            %s %s $var
        }
    `,
    procName, _dtkCallbackIdent, "updated_var");

    app.evalFmt(`set %s ""`, varName);

    stderr.writeln(app.evalFmt(`trace add variable %s write "%s updated_var $%s"`, varName, _dtkCallbackIdent, varName));

    app.evalFmt(`set %s "bar"`, varName);




    //~ Tcl_CreateObjCommand(App._interp,
                         //~ cast(char*)_dtkCallbackIdent.toStringz,
                         //~ &dtkCallbackHandler,
                         //~ null,  // no extra client data
                         //~ &dtkCallbackDeleter);


    //~ varName, tracerFunc, varName);

    //~ app.eval("ttk::style element names").print;
    //~ app.eval("ttk::style element options thumb").print;
    //~ app.eval("ttk::style theme names").print;
    //~ app.eval("ttk::style theme use clam").print;

    //~ auto button1 = new Button(app, "Flash");
    //~ button1.pack();

    //~ app.run();

    //~ % wish8.5
    // create a button, passing two options:
    //~ app.eval(`grid [ttk::button .b -text "Hello" -command {button_pressed}]`).print;

    //~ // check the current value of the text option:
    //~ app.eval(`.b cget -text`).print;

    //~ // check the current value of the command option:
    //~ app.eval(`.b cget -command`).print;

    //~ // change the value of the text option:
    //~ app.eval(`.b configure -text Goodbye`).print;

    //~ // check the current value of the text option:
    //~ app.eval(`.b cget -text`).print;

    //~ // get all information about the text option:
    //~ app.eval(`.b configure -text`).print;

    //~ // get information on all options for this widget:
    //~ app.eval(`.b configure`).print;
}
