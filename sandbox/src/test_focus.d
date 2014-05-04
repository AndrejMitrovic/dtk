module test_focus;

import core.thread;

import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk;

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto button1 = new Button(testWindow, "Button 1");
    button1.grid.setRow(0).setCol(0);

    auto button2 = new Button(testWindow, "Button 2");
    button2.grid.setRow(0).setCol(1);

    button1.onMouseEvent ~= (scope Event event)
    {
        //~ stderr.writeln(app.mainWindow.allowFocus);
        //~ stderr.writefln(button1.allowFocus);
        //~ stderr.writefln(button2.allowFocus);

        //~ button1.allowFocus = false;
        //~ assert(!button1.allowFocus);
    };

    testWindow.allowFocus = true;
    testWindow.useDefaultFocus();

    testWindow.onSinkEvent ~= (scope Event event)
    {
        if (event.type == EventType.focus)
        {
            auto fe = cast(FocusEvent)event;
            if (fe.action == FocusAction.request && fe.widget is button1)
            {
                //~ stderr.writefln("Focus event: %s", fe);

                //~ fe.allowFocus = false;
                //~ testWindow.allowFocus = true;

                fe.handled = true;
            }

            //~ stderr.writefln("Focus event: %s", cast(FocusEvent)event);
        }

        //~ if (event.action == FocusAction.request)
        //~ {
            //~ stderr.writefln("Focus request to : %s", event.widget);

            //~ if (event.widget is button1)
                //~ event.allowFocus = false;
        //~ }
        //~ else
        //~ if (event.action == FocusAction.focus)
        //~ {
            //~ stderr.writefln("Focus in to : %s", event.widget);
        //~ }
        //~ else
        //~ if (event.action == FocusAction.unfocus)
        //~ {
            //~ stderr.writefln("Focus out of: %s", event.widget);
        //~ }
    };

    tclEvalFmt("event generate %s <KeyPress> -keysym %s", testWindow.getTclName(), newChar);
    ++expectedCallCount;

    action = KeyboardAction.release;
    tclEvalFmt("event generate %s <KeyRelease> -keysym %s", testWindow.getTclName(), newChar);

    app.run();
}

void main()
{
}
