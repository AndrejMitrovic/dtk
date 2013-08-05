module window;

import std.conv;
import std.stdio;
import std.range;

import dtk;

void main()
{
    auto app = new App();

    auto window = app.mainWindow;

    window.position = Point(200, 200);
    assert(window.position == Point(200, 200));

    window.position = Point(-200, -200);
    assert(window.position == Point(-200, -200));

    window.size = Size(300, 400);
    assert(window.size == Size(300, 400));

    window.geometry = Rect(-100, 100, 250, 250);
    assert(window.position == Point(-100, 100));
    assert(window.size == Size(250, 250));
    assert(window.geometry == Rect(-100, 100, 250, 250));

    window.geometry = Rect(100, 100, 250, 250);
    assert(window.position == Point(100, 100));
    assert(window.size == Size(250, 250));
    assert(window.geometry == Rect(100, 100, 250, 250));

    //~ stderr.writeln(window.geometry);
    // @bug: http://stackoverflow.com/questions/18043720/odd-results-for-wm-geometry

    auto button1 = new Button(window, "FooButton");
    auto button2 = new Button(window, "BarButton");

    auto children = window.childWidgets;
    assert(children.front is button1);
    children.popFront();
    assert(children.front is button2);

    app.run();
}
