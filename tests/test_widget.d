module mainWin;

import std.conv;
import std.stdio;
import std.range;

import dtk;

// todo: test any widget-specific functions once
// we implement all standard Tk widgets

void main()
{
    auto app = new App();

    auto mainWin = app.mainWindow;

    app.run();
}
