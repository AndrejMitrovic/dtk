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

    auto image = new Image(r"../tests/small_button.png");

    // button
    auto button = new Button(testWindow, "Flash");
    button.pack();

    assert(button.image is null);

    button.image = null;
    assert(button.image is null);

    button.image = image;
    assert(button.image is image);

    // check button
    auto checkButton = new CheckButton(testWindow, "Flash");
    checkButton.pack();

    assert(checkButton.image is null);

    checkButton.image = null;
    assert(checkButton.image is null);

    checkButton.image = image;
    assert(checkButton.image is image);

    // label
    auto label = new Label(testWindow);
    label.pack();

    assert(label.image is null);

    label.image = null;
    assert(label.image is null);

    label.image = image;
    assert(label.image is image);

    label.text = "text image";

    assert(label.compound == Compound.none);

    label.compound = Compound.center;
    assert(label.compound == Compound.center);

    app.run();
}

void main()
{
}
