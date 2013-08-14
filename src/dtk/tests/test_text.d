module dtk.tests.test_text;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.range;
import std.stdio;
import std.string;

import dtk;
import dtk.tests.globals;

unittest
{
    auto text = new Text(app.mainWindow);
    text.pack();

    text.size = Size(50, 10);
    assert(text.size == Size(50, 10));

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
