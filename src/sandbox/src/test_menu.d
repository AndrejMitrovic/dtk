module test_menu;

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
    auto window = app.mainWindow;

    assert(window.menubar is null);
    auto menuBar = window.createMenuBar();
    assert(window.menubar is menuBar);

    auto helpMenu = menuBar.addMenu("Help");
    assert(helpMenu.label == "Help");

    // put the file menu before the help menu
    auto fileMenu = menuBar.insertMenu(0, "File");

    // put the edit menu before the help menu
    auto editMenu = menuBar.insertMenu(1, "Edit");

    auto moreEdit = editMenu.addMenu("More...");

    auto openFileItem = fileMenu.addItem("Open...");
    assert(openFileItem.label == "Open...");

    // put the new file command before the edit command
    auto newFileItem = fileMenu.insertItem(0, "New");
    assert(newFileItem.label == "New");

    fileMenu.addSeparator();

    fileMenu.addItem("Print");
    fileMenu.insertSeparator(4);
    fileMenu.addItem("Settings");
    fileMenu.addItem("Exit");

    fileMenu.addSeparator();

    auto showWindowCheck = fileMenu.addToggleItem("Show Window", "0", "1");

    auto showTipsToggle = fileMenu.insertToggleItem(8, "Show Tips");

    fileMenu.addSeparator();
    auto colorMenu = fileMenu.addMenu("Color Scheme");
    colorMenu.addRadioGroup(RadioItem("Red", "set-red"),
                            RadioItem("Green", "set-green"),
                            RadioItem("Orange"),  // value is "Orange"
                            RadioItem("Blue", "set-blue"));

    fileMenu.insertSeparator(7);
    fileMenu.insertRadioGroup(8, RadioItem("First", "set-first"),
                                 RadioItem("Second", "set-second"),
                                 RadioItem("Third", "set-third"));

    auto encMenu = fileMenu.insertMenu(1, "Encoding");
    encMenu.addRadioGroup(RadioItem("UTF-8"), RadioItem("UTF-16"), RadioItem("UTF-32"));

    menuBar.onMenuEvent ~= (scope MenuEvent e)
    {
        stderr.writefln("Menu event: %s", e);
    };

    app.run();
}

void main()
{
}
