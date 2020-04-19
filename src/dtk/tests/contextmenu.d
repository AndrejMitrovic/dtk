/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.contextmenu;

version(unittest):

import dtk;
import dtk.tests.globals;

unittest
{
    /+ auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    assert(testWindow.menubar is null);
    assert(testWindow.contextMenu is null);

    auto menuBar = new MenuBar();

    /** Using both menus for the main menu and the context menu */
    testWindow.menubar = menuBar;
    assert(testWindow.menubar is menuBar);

    testWindow.contextMenu = menuBar;
    assert(testWindow.contextMenu is menuBar);

    auto helpMenu = new Menu("Help");
    assert(helpMenu.label == "Help");

    /*
        major todo: we cannot add these child widgets until the parent is initialized,
        but the parent is only initialized when we assign the menu to the parent.

        Some possible workarounds:

        - Only allow instantiating MenuBars from within the window, e.g. window.createMenuBar,
        and context menus via window.createContextMenu.

        - Make a more sophisticated delayed initialization mechanism, which only instantiates
        widgets from parent to child once they're all properly linked together. This could end
        up being arbitrarily hard to implement.
    */
    menuBar.addMenu(helpMenu);

    // put the file menu before the help menu
    auto fileMenu = new Menu("File");
    menuBar.insertMenu(fileMenu, 0);

    // put the edit menu before the help menu
    auto editMenu = new Menu("Edit");
    menuBar.insertMenu(editMenu, 1);

    auto openFileItem = new MenuItem("Open Files...");
    assert(openFileItem.label == "Open Files...");
    fileMenu.addItem(openFileItem);

    openFileItem.onEvent.connect(
    (Widget widget, Event event)
    {
        if (event.type == EventType.TkMenuItemSelect)
        {
            stderr.writefln("Selected item openFile");
        }
    }
    );

    // put the new file command before the edit command
    auto newFileItem = new MenuItem("New");
    assert(newFileItem.label == "New");
    fileMenu.insertItem(newFileItem, 0);

    fileMenu.addSeparator();

    fileMenu.addItem(new MenuItem("Print"));
    fileMenu.insertSeparator(4);
    fileMenu.addItem(new MenuItem("Settings"));
    fileMenu.addItem(new MenuItem("Exit"));

    newFileItem.onEvent.connect(
    (Widget widget, Event event)
    {
        if (event.type == EventType.TkMenuItemSelect)
        {
            stderr.writefln("Selected item newFile");
        }
    }
    );

    fileMenu.addSeparator();

    auto showWindowCheck = new CheckMenuItem("Show Window", "enable-window", "disable-window");
    fileMenu.addItem(showWindowCheck);

    showWindowCheck.onEvent.connect(
    (Widget widget, Event event)
    {
        if (event.type == EventType.TkCheckMenuItemToggle)
        {
            stderr.writefln("Toggled '%s' to '%s'.", showWindowCheck.label, event.state);
        }
    }
    );

    auto showTipsCheck = new CheckMenuItem("Show Tips");
    fileMenu.insertItem(showTipsCheck, 8);

    showTipsCheck.onEvent.connect(
    (Widget widget, Event event)
    {
        if (event.type == EventType.TkCheckMenuItemToggle)
        {
            stderr.writefln("Toggled '%s' to '%s'.", showTipsCheck.label, event.state);
        }
    }
    );

    auto radioMenuGroup = new RadioGroupMenu();
    auto radio1 = new RadioMenuItem(radioMenuGroup, "Red", "set-red");
    auto radio2 = new RadioMenuItem(radioMenuGroup, "Green", "set-green");
    auto radio3 = new RadioMenuItem(radioMenuGroup, "Blue", "set-blue");

    radioMenuGroup.onEvent.connect(
    (Widget widget, Event event)
    {
        if (event.type == EventType.TkRadioMenuSelect)
        {
            stderr.writefln("Radio selected: '%s'.", event.state);
        }
    }
    );

    fileMenu.addSeparator();
    fileMenu.addItem(radioMenuGroup);

    auto n_radioMenuGroup = new RadioGroupMenu();
    auto n_radio1 = new RadioMenuItem(n_radioMenuGroup, "First", "set-first");
    auto n_radio2 = new RadioMenuItem(n_radioMenuGroup, "Second", "set-second");
    auto n_radio3 = new RadioMenuItem(n_radioMenuGroup, "Third", "set-third");

    n_radioMenuGroup.onEvent.connect(
    (Widget widget, Event event)
    {
        if (event.type == EventType.TkRadioMenuSelect)
        {
            stderr.writefln("Radio selected: '%s'.", event.state);
        }
    }
    );

    fileMenu.insertSeparator(7);
    fileMenu.insertItem(n_radioMenuGroup, 8);

    app.testRun(); +/
}
