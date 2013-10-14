/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.events_generic;

version(unittest):
version(DTK_UNITTEST):

import dtk;
import dtk.imports;
import dtk.utils;
import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto frame = new Frame(testWindow);
    auto button = new Button(frame, "Button");

    frame.pack();
    button.pack();

    size_t callCount;
    size_t expectedCallCount;

    button.onMouseEvent ~= (scope MouseEvent e) { ++callCount; };
    button.onMouseEvent ~= (scope Event e) { ++callCount; };
    button.onMouseEvent ~= () { ++callCount; };

    void genEvent()
    {
        // note: generating keyboard events is unreliable (they need a focused widget),
        // mouse click events generate multi-click events.
        // Generating a mouse wheel event is the easiest thing to do.
        tclEvalFmt("event generate %s <MouseWheel> -delta 120", button.getTclName());
    }

    void checkCallCount(string file = __FILE__, size_t line = __LINE__)
    {
        if (callCount != expectedCallCount)
            throw new Exception(format("calls (%s) != (%s) expected", callCount, expectedCallCount), file, line);
    }

    /* Test event sequencing. */

    genEvent();
    expectedCallCount += 3;

    button.onMouseEvent.connectFront((scope MouseEvent e) { assert(e.travel == EventTravel.target); e.handled = true; });
    genEvent();  // event blocked

    button.onMouseEvent.disconnectFront();
    genEvent();
    expectedCallCount += 3;
    checkCallCount();

    button.onMouseEvent.disconnectBack();
    genEvent();
    expectedCallCount += 2;
    checkCallCount();

    button.onMouseEvent.disconnectBack();
    genEvent();
    expectedCallCount += 1;
    checkCallCount();

    button.onMouseEvent.disconnectBack();
    genEvent();  // no event handlers left
    checkCallCount();

    button.onMouseEvent ~= () { callCount += 1; };
    button.onMouseEvent ~= () { callCount += 2; };
    button.onMouseEvent ~= () { callCount += 3; };
    genEvent();
    expectedCallCount += 6;
    checkCallCount();

    button.onMouseEvent.disconnectFront();
    genEvent();
    expectedCallCount += 5;
    checkCallCount();

    button.onMouseEvent.disconnectBack();
    genEvent();
    expectedCallCount += 2;
    checkCallCount();

    button.onMouseEvent.clear();
    genEvent();  // no event handlers left
    checkCallCount();

    /* Prepare event handlers for new tests. */

    button.onMouseEvent ~= () { ++callCount; };
    button.onMouseEvent ~= () { ++callCount; };
    button.onMouseEvent ~= () { ++callCount; };

    /* Test event filtering. */

    button.onFilterEvent ~= (scope Event e) { assert(e.travel == EventTravel.filter); e.handled = true; };
    genEvent();  // event handled
    checkCallCount();

    button.onFilterEvent.clear();
    genEvent();
    expectedCallCount += 3;
    checkCallCount();

    /* Test event sinking. */
    button.parentWidget.onSinkEvent ~= (scope Event e) { assert(e.travel == EventTravel.sink); e.handled = true; };
    genEvent();  // event handled
    checkCallCount();

    button.parentWidget.onSinkEvent.clear();
    genEvent();
    expectedCallCount += 3;
    checkCallCount();

    /* Test event notification. */

    button.onNotifyEvent ~= (scope Event e) { assert(e.travel == EventTravel.notify); ++callCount; };
    button.onNotifyEvent ~= () { ++callCount; };

    button.onFilterEvent ~= (scope Event e) { e.handled = true; };
    genEvent();  // event handled
    checkCallCount();

    button.onFilterEvent.clear();
    genEvent();
    expectedCallCount += 3 + 2;  // 3 handlers and 2 notify listeners
    checkCallCount();

    button.onNotifyEvent.connectFront((scope Event e) { ++callCount; e.handled = true; });
    genEvent();
    expectedCallCount += 3 + 1 /* + 2 */;  // 3 handlers, 1 notify, (2 notify blocked)
    checkCallCount();
    button.onNotifyEvent.clear();

    /* Test event bubbling. */
    button.parentWidget.onBubbleEvent ~= (scope Event e) { assert(e.travel == EventTravel.bubble); ++callCount; };
    genEvent();
    expectedCallCount += 3 + 1;  // 3 handlers and 1 bubble event
    checkCallCount();

    // does not block bubble event
    button.onNotifyEvent ~= (scope Event e) { ++callCount; e.handled = true; };
    genEvent();
    expectedCallCount += 3 + 1 + 1;  // 3 handlers, 1 notify, 1 bubble
    checkCallCount();

    button.parentWidget.parentWidget.onBubbleEvent ~= () { ++callCount; };
    genEvent();
    expectedCallCount += 3 + 1 + 1 + 1;  // 3 handlers, 1 notify, 1 bubble, 1 bubble
    checkCallCount();

    // block further parents from getting bubble events
    button.parentWidget.onBubbleEvent.connectFront((scope Event e) { ++callCount; e.handled = true; });
    genEvent();
    expectedCallCount += 3 + 1 + 1 /* + 1 */;  // 3 handlers, 1 notify, 1 bubble, (1 bubble blocked)
    checkCallCount();

    button.parentWidget.onBubbleEvent.clear();
    button.parentWidget.parentWidget.onBubbleEvent.clear();
    button.onNotifyEvent.clear();

    /* Test generic and specific event handling. */
    button.onEvent ~= () { ++callCount; };
    genEvent();
    expectedCallCount += 1 + 3;  // 1 generic, 3 specific
    checkCallCount();

    button.parentWidget.onBubbleEvent ~= () { ++callCount; };
    genEvent();
    expectedCallCount += 1 + 3 + 1;  // 1 generic, 3 specific, 1 bubble
    checkCallCount();
    button.parentWidget.onBubbleEvent.clear();

    button.onEvent.connectFront((scope Event event) { ++callCount; event.handled = true; });
    genEvent();
    expectedCallCount += 1 /* + 3*/;  // 1 generic, (3 specific blocked)
    checkCallCount();

    button.parentWidget.onBubbleEvent ~= () { ++callCount; };
    genEvent();
    expectedCallCount += 1 /* + 3 */ + 1;  // 1 generic, (3 specific blocked), 1 bubble
    checkCallCount();
    button.onEvent.clear();
    button.onMouseEvent.clear();
    button.parentWidget.onBubbleEvent.clear();

    button.onEvent ~= () { ++callCount; };
    button.onMouseEvent ~= (scope Event event) { ++callCount; event.handled = true; };
    button.parentWidget.onBubbleEvent ~= () { ++callCount; };
    genEvent();
    expectedCallCount += 1 + 1 + 1;  // 1 generic, 1 specific, 1 bubble
    checkCallCount();

    app.testRun();
}
