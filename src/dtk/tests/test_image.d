/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.test_image;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.ascii;
import std.algorithm;
import std.range;
import std.stdio;
import std.string;

import dtk;

import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto image = new Image("../tests/small_button.png");

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
    auto radioGroup = new RadioGroup(testWindow);
    auto radio1 = radioGroup.addButton("Set On", "on");
    auto radio2 = radioGroup.addButton("Set Off", "off");

    auto diskRed = new Image("../tests/disk_red.png");
    auto diskBlue = new Image("../tests/disk_blue.png");

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

    auto tree = new Tree(testWindow, "Directory Name", ["File Name", "Modified Date", "Created"]);
    auto root1 = tree.add("Root 1");
    auto root2 = tree.add("Root 2");
    root1.add("Child 1.1");
    root1.add("Child 1.2");
    root2.add("Child 2.1");
    root2.add("Child 2.2");
    tree.pack();

    root1.values = ["2012-04-05", "2012-01-01"];
    root1.isOpened = true;
    root1.column.text = "Root 1";
    root1.column.image = diskRed;

    root2.values = ["2012-04-05", "2012-01-01"];
    root2.isOpened = true;
    root2.column.text = "Root 2";
    root2.column.image = diskBlue;

    tree.headings[0].text = "Dirname";
    tree.headings[0].anchor = Anchor.center;
    tree.headings[0].image = diskRed;

    tree.headings[1].text = "Filename";
    tree.headings[1].anchor = Anchor.center;
    tree.headings[1].image = diskBlue;

    app.testRun();
}
