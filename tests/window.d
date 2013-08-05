module window;

import std.stdio;
import std.range;

import dtk;

void main()
{
    auto app = new App();

    auto window = app.mainWindow;

    auto newGeo = Geometry(100, 100, 250, 250);

    window.geometry = newGeo;
    assert(window.position == Point(100, 100));
    assert(window.geometry == newGeo);

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
