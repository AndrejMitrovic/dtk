module test_image;

import core.thread;

import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk;
import dtk.tests.globals;

unittest
{
    auto app = new App;
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto button = new Button(testWindow, "Flash");
    button.pack();

    assert(button.image is null);

    auto image = new Image(r"../tests/button.png");
    button.image = image;

    assert(button.image is image);

    //~ button.size = Size(50, 50);

    app.run();
}

void main()
{
}
