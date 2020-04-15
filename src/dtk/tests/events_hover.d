/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.events_hover;

version(unittest):

import dtk;
import dtk.imports;
import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);

    auto frame = new Frame(testWindow);

    auto button1 = new Button(frame, "Flash Button");
    frame.pack();
    button1.pack();

    HoverAction action;

    size_t callCount;
    size_t expectedCallCount;

    auto handler = (scope HoverEvent e)
    {
        assert(e.widget is button1);
        assert(e.action == action);
        ++callCount;
    };

    button1.onHoverEvent ~= handler;

    action = HoverAction.enter;
    tclEvalFmt("event generate %s <Enter> -x 0 -y 0", button1.getTclName());
    ++expectedCallCount;

    action = HoverAction.leave;
    tclEvalFmt("event generate %s <Leave> -x 200 -y 200", button1.getTclName());
    ++expectedCallCount;

    assert(callCount == expectedCallCount, text(callCount, " != ", expectedCallCount));

    app.testRun();
}
