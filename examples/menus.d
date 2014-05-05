/*
 *             Copyright Andrej Mitrovic 2014.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module menus;

import std.string : format;

import dtk;

void main()
{
    auto app = new App();

    // Get the reference to the implicitly created main window.
    auto window = app.mainWindow;
    window.title = "Menus example";
    window.size = Size(500, 200);

    // Position it in the center.
    window.centerWindow();

    // The menu bar will contain Menus such as File / Edit / Help, etc.
    auto menuBar = window.createMenuBar();

    // We will display some text based on the menu actions here.
    auto status = new Label(window, "Clicked menu is shown here.");
    status.pack();

    // Add a generic handler for any menu events for the current app.
    menuBar.onMenuEvent ~= (scope MenuEvent e)
    {
        status.text = format("Menu event:\n\n%s", e);
    };

    // Add a Help menu at the first position.
    auto helpMenu = menuBar.addMenu("Help");

    // Add an item to the Help menu.
    helpMenu.addItem("Show Help");

    // Insert the File menu at the first position.
    auto fileMenu = menuBar.insertMenu(0, "File");

    // Insert the Edit menu before the Help menu.
    auto editMenu = menuBar.insertMenu(1, "Edit");

    // Add some items to the Edit menu.
    editMenu.addItem("Cut");
    editMenu.addItem("Copy");
    editMenu.addItem("Paste");

    // Add a submenu inside the Edit menu.
    auto moreEdit = editMenu.addMenu("More...");

    // Add a command inside the File menu.
    auto openFileItem = fileMenu.addItem("Open...");

    // Insert a command before the Open command in the File menu.
    auto newFileItem = fileMenu.insertItem(0, "New");

    // Add a separator after all existing commands in the File menu.
    fileMenu.addSeparator();

    // Add a cople of more commands to the File menu.
    fileMenu.addItem("Print");
    fileMenu.insertSeparator(4);

    fileMenu.addItem("Settings");
    fileMenu.addItem("Exit");
    fileMenu.addSeparator();

    // Add a toggle command in the File menu.
    auto showWindowCheck = fileMenu.addToggleItem("Show Window", "0", "1");

    // Insert a toggle command in the File menu.
    auto showTipsToggle = fileMenu.insertToggleItem(8, "Show Tips");
    fileMenu.addSeparator();

    // Add a set of radio-selection items in the File menu.
    auto colorMenu = fileMenu.addMenu("Color Scheme");
    colorMenu.addRadioGroup(RadioItem("Red", "set-red"),
                            RadioItem("Green", "set-green"),
                            RadioItem("Orange"),  // value is "Orange"
                            RadioItem("Blue", "set-blue"));

    // Add another set of radio-selection items in the File menu.
    fileMenu.insertSeparator(7);
    fileMenu.insertRadioGroup(8, RadioItem("First", "set-first"),
                                 RadioItem("Second", "set-second"),
                                 RadioItem("Third", "set-third"));

    // Add a set of radio-selection items inside a submenu in the File menu.
    auto encMenu = fileMenu.insertMenu(1, "Encoding");
    encMenu.addRadioGroup(RadioItem("UTF-8"),
                          RadioItem("UTF-16"),
                          RadioItem("UTF-32"));

    app.run();
}
