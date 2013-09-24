module test_events_generic;

import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import std.string;
import std.traits;
import std.typetuple;

import dtk;

unittest
{
    auto app = new App;

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

    button.onMouseEvent.connectFront((scope MouseEvent e) { e.handled = true; });
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

    button.onMouseEvent ~= (scope MouseEvent e) { ++callCount; };
    button.onMouseEvent ~= (scope Event e) { ++callCount; };
    button.onMouseEvent ~= () { ++callCount; };

    /* Test event filtering. */

    button.onFilterEvent ~= (scope Event e) { e.handled = true; };
    genEvent();  // event handled
    checkCallCount();

    button.onFilterEvent.clear();
    genEvent();
    expectedCallCount += 3;
    checkCallCount();

    /* Test event sinking. */
    button.parentWidget.onSinkEvent ~= (scope Event e) { e.handled = true; };
    genEvent();  // event handled
    checkCallCount();

    button.parentWidget.onSinkEvent.clear();
    genEvent();
    expectedCallCount += 3;
    checkCallCount();

    /* Test event notification. */

    button.onNotifyEvent ~= (scope Event e) { ++callCount; };
    button.onNotifyEvent ~= (scope Event e) { ++callCount; };

    button.onFilterEvent ~= (scope Event e) { e.handled = true; };
    genEvent();  // event handled
    checkCallCount();

    button.onFilterEvent.clear();
    genEvent();
    expectedCallCount += 3 + 2;  // 3 handlers and 2 notify listeners
    checkCallCount();

    button.onNotifyEvent.connectFront((scope Event e) { ++callCount; e.handled = true; });
    genEvent();
    expectedCallCount += 3 + 1 /* + 2 */;  // 3 handlers and 1 notify listener which blocked the extra 2
    checkCallCount();
    button.onNotifyEvent.clear();

    /* Test event bubbling. */
    button.parentWidget.onBubbleEvent ~= (scope Event e) { ++callCount; };
    genEvent();
    expectedCallCount += 3 + 1;  // 3 handlers and 1 bubble event
    checkCallCount();

    // does not block bubble event
    button.onNotifyEvent ~= (scope Event e) { ++callCount; e.handled = true; };
    genEvent();
    expectedCallCount += 3 + 1 + 1;  // 3 handlers, 1 notify, 1 bubble
    checkCallCount();

    button.parentWidget.parentWidget.onBubbleEvent ~= (scope Event e) { ++callCount; };
    genEvent();
    expectedCallCount += 3 + 1 + 1 + 1;  // 3 handlers, 1 notify, 1 bubble, 1 bubble
    checkCallCount();

    // block further parents from getting bubble events
    button.parentWidget.onBubbleEvent.connectFront((scope Event e) { ++callCount; e.handled = true; });
    genEvent();
    expectedCallCount += 3 + 1 + 1 /* + 1 */;  // 3 handlers, 1 notify, 1 bubble (1 bubble blocked)
    checkCallCount();

    app.run();
}

void main()
{
}
