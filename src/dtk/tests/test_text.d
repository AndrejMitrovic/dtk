/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.test_text;

version(unittest):
version(DTK_UNITTEST):

import dtk;
import dtk.imports;
import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto text = new Text(testWindow);
    text.pack();

    text.textSize = Size(50, 10);
    assert(text.textSize == Size(50, 10));

    text.wrapMode = WrapMode.none;
    assert(text.wrapMode == WrapMode.none);

    text.wrapMode = WrapMode.word;
    assert(text.wrapMode == WrapMode.word);

    text.value = "asdf";
    assert(text.value == "asdf");

    text.value = "a b c d e f g h foo bar doo";
    assert(text.value == "a b c d e f g h foo bar doo");

    app.testRun();
}
