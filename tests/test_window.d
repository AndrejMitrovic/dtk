module mainWin;

import std.conv;
import std.stdio;
import std.range;

import dtk;

void main()
{
    auto app = new App();

    auto mainWin = app.mainWindow;

    mainWin.position = Point(200, 200);
    assert(mainWin.position == Point(200, 200));

    // e.g. Size(1680, 1050)
    //~ stderr.writeln(mainWin.screenSize);

    mainWin.position = Point(-200, -200);
    assert(mainWin.position == Point(-200, -200));

    mainWin.size = Size(300, 400);
    assert(mainWin.size == Size(300, 400));

    mainWin.geometry = Rect(-100, 100, 250, 250);
    assert(mainWin.position == Point(-100, 100));
    assert(mainWin.size == Size(250, 250));
    assert(mainWin.geometry == Rect(-100, 100, 250, 250));

    mainWin.geometry = Rect(100, 100, 250, 250);
    assert(mainWin.position == Point(100, 100));
    assert(mainWin.size == Size(250, 250));
    assert(mainWin.geometry == Rect(100, 100, 250, 250));

    //~ stderr.writeln(mainWin.geometry);
    // @bug: http://stackoverflow.com/questions/18043720/odd-results-for-wm-geometry

    assert(mainWin.parentWindow is null);
    auto childWin = new Window(mainWin, 100, 100);
    assert(mainWin.parentWindow is null);
    assert(childWin.parentWindow is mainWin);

    auto button1 = new Button(mainWin, "FooButton");
    auto button2 = new Button(mainWin, "BarButton");

    auto children = mainWin.childWidgets;
    assert(children.front is childWin);
    children.popFront();
    assert(children.front is button1);
    children.popFront();
    assert(children.front is button2);

    app.run();
}
