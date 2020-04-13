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
    auto testWindow = new Window(app.mainWindow, 300, 300);
    testWindow.position = Point(500, 500);

    auto image = new Image("small_button.png");

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

    // radio button
    auto radioGroup = new RadioGroup();
    auto radio1 = new RadioButton(testWindow, radioGroup, "Set On", "on");
    auto radio2 = new RadioButton(testWindow, radioGroup, "Set Off", "off");

    auto diskRed = new Image("disk_red.png");
    auto diskBlue = new Image("disk_blue.png");

    radio1.image = diskRed;
    radio2.image = diskBlue;

    radio1.pack();
    radio2.pack();

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


    TabOptions options;
    options.text = "Cool button 1";
    options.image = image;
    options.compound = Compound.center;

    // notebook
    auto book = new Notebook(testWindow);

    auto button1 = new Button(book, "Button1");
    auto button2 = new Button(book, "Button2");
    auto button3 = new Button(book, "Button3");

    book.add(button1, button1.text);
    book.add(button2, button2.text);
    book.add(button3, button3.text);

    book.setOptions(button1, options);
    assert(book.options(button1) == options, format("\n%s\n!=\n%s", book.options(button1), options));

    book.pack();

    auto tree = new Tree(testWindow, "Directory", ["Filename", "Modified", "Created"]);
    auto root1 = tree.add("Root 1");
    auto root2 = tree.add("Root 2");
    root1.add("Child 1.1");
    root1.add("Child 1.2");
    root2.add("Child 2.1");
    root2.add("Child 2.2");
    tree.pack();

    auto rowOpts1 = RowOptions("Root 1", diskRed, ["2012-04-05", "2012-01-01"], IsOpened.yes);
    root1.rowOptions = rowOpts1;
    assert(root1.rowOptions == rowOpts1);

    auto rowOpts2 = RowOptions("Root 2", diskBlue, ["2012-04-05", "2012-01-01"], IsOpened.yes);
    root2.rowOptions = rowOpts2;
    assert(root2.rowOptions == rowOpts2);

    auto headOpts1 = HeadingOptions("Dirname", Anchor.center, diskRed);
    tree.setHeadingOptions(0, headOpts1);
    assert(tree.headingOptions(0) == headOpts1);

    auto headOpts2 = HeadingOptions("Filename", Anchor.center, diskBlue);
    tree.setHeadingOptions(1, headOpts2);
    assert(tree.headingOptions(1) == headOpts2);

    app.run();
}

void main()
{
}
