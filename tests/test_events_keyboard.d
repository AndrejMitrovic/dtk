module test_events_keyboard;

import std.algorithm;
import std.range;
import std.stdio;
import std.traits;
import std.typetuple;

import dtk;

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 200, 200);

    bool ignoreEvents;  // Tk double-click behavior workaround

    //~ int wheel;
    //~ MouseAction action;
    //~ MouseButton button;
    //~ KeyMod keyMod;
    //~ Point widgetMousePos;

    //~ // we only want to test this when we explicitly generate move events,
    //~ // since the mouse can be at an arbitrary point when generating non-move events.
    //~ enum MotionTest { none, widget, desktop }
    //~ MotionTest motionTest;
    //~ Point desktopMousePos;

    auto handler = (scope KeyboardEvent e)
    {
        //~ if (ignoreEvents)
            //~ return;

        //~ assert(e.action == action, text(action, " ", e.action));
        //~ assert(e.button == button, text(button, " ", e.button));
        //~ assert(e.wheel  == wheel,  text(wheel,  " ", e.wheel));
        //~ assert(e.keyMod == keyMod, text(keyMod, " ", e.keyMod));

        //~ switch (motionTest)
        //~ {
            //~ case MotionTest.widget:
                //~ assert(e.widgetMousePos == widgetMousePos, text(widgetMousePos, " ", e.widgetMousePos));
                //~ break;

            //~ case MotionTest.desktop:
                //~ assert(e.desktopMousePos == desktopMousePos, text(desktopMousePos, " ", e.desktopMousePos));
                //~ break;

            //~ default:
        //~ }
    };

    testWindow.onKeyboardEvent = handler;

    tclEvalFmt("event generate %s <ButtonPress> -button %s", testWindow.getTclName(), ((buttonIdx - 2) % mouseButtons.length));


    app.run();
}

void main()
{
}
