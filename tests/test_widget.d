module mainWin;

import std.conv;
import std.stdio;
import std.range;

import dtk;

void main()
{
    auto app = new App();

    auto mainWin = app.mainWindow;

    app.run();
}
