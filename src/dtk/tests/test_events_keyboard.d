module dtk.tests.test_events_keyboard;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.range;
import std.stdio;
import std.string;

static if (__VERSION__ < 2064)
    import dtk.all;
else
    import dtk;

import dtk.tests.globals;

//~ void handleEvent(scope Event event)
//~ {
//~ }

//~ void handleKeyboardEvent(scope KeyboardEvent event)
//~ {
//~ }

unittest
{
    //~ auto testWindow = new Window(app.mainWindow, 200, 200);

    //~ testWindow.onEvent = &handleEvent;
    //~ testWindow.onKeyboardEvent = &handleKeyboardEvent;

    //~ app.testRun();
}
