module dtk.tests.test_window;

version(unittest):
version(DTK_UNITTEST):

import std.conv;
import std.stdio;
import std.range;

import dtk;
import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);

    testWindow.position = Point(200, 200);
    assert(testWindow.position == Point(200, 200));

    // e.g. Size(1680, 1050)
    //~ logf(testWindow.screenSize);

    testWindow.position = Point(-200, -200);
    assert(testWindow.position == Point(-200, -200));

    testWindow.size = Size(300, 400);
    assert(testWindow.size == Size(300, 400));

    testWindow.geometry = Rect(-100, 100, 250, 250);
    assert(testWindow.position == Point(-100, 100));
    assert(testWindow.size == Size(250, 250));
    assert(testWindow.geometry == Rect(-100, 100, 250, 250));

    testWindow.geometry = Rect(100, 100, 250, 250);
    assert(testWindow.position == Point(100, 100));
    assert(testWindow.size == Size(250, 250));
    assert(testWindow.geometry == Rect(100, 100, 250, 250));

    //~ logf(testWindow.geometry);
    // @bug: http://stackoverflow.com/questions/18043720/odd-results-for-wm-geometry

    assert(testWindow.parentWindow is app.mainWindow);

    auto childWin = new Window(testWindow, 100, 100);
    assert(testWindow.parentWindow is app.mainWindow);
    assert(childWin.parentWindow is testWindow);

    childWin.setAlpha(0.5);
    assert(childWin.getAlpha() < 0.6);
    childWin.setAlpha(1.0);

    childWin.maximizeWindow();
    childWin.unmaximizeWindow();

    auto button1 = new Button(testWindow, "FooButton");
    auto button2 = new Button(testWindow, "BarButton");

    auto children = testWindow.childWidgets;
    assert(children.front is childWin);
    children.popFront();
    assert(children.front is button1);
    children.popFront();
    assert(children.front is button2);

    testWindow.setTopWindow();
    childWin.setTopWindow();

    testWindow.minimizeWindow();
    testWindow.unminimizeWindow();

    testWindow.title = "my window";
    assert(testWindow.title == "my window");

    app.testRun();
}
