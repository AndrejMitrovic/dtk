module test_window;

import dtk;

unittest
{
    auto app = new App;
    auto testWindow = new Window(app.mainWindow, 200, 200);

    app.mainWindow.position = Point(200, 200);
    testWindow.position = Point(200, 200);

    testWindow.setAlpha(0.0);

    app.run();
}

void main()
{
}
