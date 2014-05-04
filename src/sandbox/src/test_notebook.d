module test_notebook;

import core.thread;

import std.conv;
import std.exception;
import std.range;
import std.stdio;
import std.string;

import dtk;
import dtk.tests.globals;

unittest
{
    auto app = new App;
    auto testWindow = new Window(app.mainWindow, 200, 200);

    auto book = new Notebook(testWindow);

    auto badButton = new Button(testWindow, "Flash");
    assertThrown(book.add(badButton));  // cannot add a widget which isn't parented to the notebook

    auto button1 = new Button(book, "Button1");
    auto button2 = new Button(book, "Button2");
    auto button3 = new Button(book, "Button3");

    book.add(button1, button1.text);
    book.add(button3, button3.text);
    book.insert(button2, 1, button2.text);

    assert(book.tabs.length == 3);

    book.remove(button1);
    book.remove(1);
    assert(book.tabs.length == 1);

    book.remove(0);
    assert(book.tabs.length == 0);

    book.add(button1, button1.text);
    book.add(button2, button2.text);
    book.add(button3, button3.text);
    assert(book.tabs.length == 3);

    assert(book.selected is button1);

    // todo: could add removeAll
    book.remove(0);
    book.remove(0);
    book.remove(0);

    book.add(button3, TabOptions(button3.text));
    book.insert(button2, 0, TabOptions(button2.text));
    book.insert(button1, 0, TabOptions(button1.text));

    assert(book.selected is button3);

    book.selected = button3;
    assert(book.selected is button3);

    book.selected = 1;
    assert(book.selected is button2);

    assert(book.indexOf(button1) == 0);
    assert(book.indexOf(button2) == 1);
    assert(book.indexOf(button3) == 2);

    assert(book.options(button1) == book.options(0));
    assert(book.options(button1).text == button1.text);

    TabOptions options;
    options.text = "Cool button 1";

    book.setOptions(button1, options);

    assert(book.options(button1) == options, format("%s != %s", book.options(button1), options));
    assert(book.options(0) == options);

    options.text = "A button 1";
    book.setOptions(0, options);
    assert(book.options(button1) == options);
    assert(book.options(0) == options);

    book.hideTab(button1);
    book.unhideTab(button1);

    book.pack();

    app.run();
}

void main()
{
}
