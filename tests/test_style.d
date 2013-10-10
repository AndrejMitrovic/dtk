module test_style;

import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk;

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto button = new Button(testWindow, "button");

    assert(button.style == GenericStyle.button);

    button.style = GenericStyle.toolButton;
    assert(button.style == GenericStyle.toolButton);

    button.style = GenericStyle.none;
    assert(button.style == GenericStyle.button);

    app.run();
}

void main()
{
}
