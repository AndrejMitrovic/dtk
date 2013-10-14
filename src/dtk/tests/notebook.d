/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.notebook;

version(unittest):
version(DTK_UNITTEST):

import dtk;
import dtk.imports;
import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto book = new Notebook(testWindow);

    auto badButton = new Button(testWindow, "Flash");
    assertThrown(book.add(badButton));  // cannot add a widget which isn't parented to the notebook

    auto button1 = new Button(book, "Button1");
    auto button2 = new Button(book, "Button2");
    auto button3 = new Button(book, "Button3");

    assert(book.walkTabs.empty);

    book.add(button1, button1.text);
    book.add(button3, button3.text);
    book.insert(button2, 1, button2.text);

    assert(!book.walkTabs.empty);

    size_t idx;
    foreach (tab; book.walkTabs)
    {
        assert(tab == book[idx], text(tab, " != ", book[idx]));
        idx++;
    }

    assert(book.length == 3);

    book[button1].remove();
    book[0].remove();
    assert(book.length == 1);

    book[0].remove();
    assert(book.length == 0);

    book.add(button1, button1.text);
    book.add(button2, button2.text);
    book.add(button3, button3.text);
    assert(book.length == 3);

    assert(book.selected is button1);

    book[0].remove();
    assert(book.length == 2);

    book.clear();
    assert(book.length == 0);

    book.add(button3);
    book.insert(button2, 0);
    book.insert(button1, 0);

    assert(book.selected is button3);

    book[button3].select();
    assert(book.selected is button3);

    book[1].select();
    assert(book.selected is button2);

    assert(book[button1].index == 0);
    assert(book[button2].index == 1);
    assert(book[button3].index == 2);

    book[button1].text = "Cool button 1";
    assert(book[button1].text == "Cool button 1");
    assert(book[0].text == "Cool button 1");

    book[0].text = "Button 1";
    assert(book[button1].text == "Button 1");
    assert(book[0].text == "Button 1");

    book[button1].compound = Compound.center;
    assert(book[button1].compound == Compound.center);

    assert(book[button1].underline == -1);

    book[button1].underline = 3;
    assert(book[button1].underline == 3);

    book[button1].underline = -1;
    assert(book[button1].underline == -1);

    book[button1].tabState = TabState.disabled;
    assert(book[button1].tabState == TabState.disabled);

    book[button1].sticky = Sticky.nse;
    assert(book[button1].sticky == Sticky.nse);

    book[button1].padding = Padding(1, 2, 3, 4);
    assert(book[button1].padding == Padding(1, 2, 3, 4));

    book[button1].hide();
    book[button1].show();

    book.pack();

    app.testRun();
}
