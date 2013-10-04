module test_dragdrop;

import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk;
import dtk.tests.globals;

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto button1 = new Button(testWindow, "Button1");
    auto button2 = new Button(testWindow, "Button2");
    auto label = new Label(testWindow);

    button1.grid.setRow(1).setCol(0);
    button2.grid.setRow(0).setCol(1);
    label.grid.setRow(2).setCol(0).setColSpan(2);

    button1.onDragDropEvent ~= (scope DragDropEvent event)
    {
        label.text = to!string(event.action);

        if (event.action == DropAction.leave)
            return;

        if (!event.hasData!string)  // only interested in text data
            return;

        event.acceptDrop = true;

        if (event.action == DropAction.drop)
        {
            string data;
            if (event.keyMod & (KeyMod.control + KeyMod.alt) && event.canMoveData)
                data = event.moveData!string();
            else
                data = event.copyData!string();

            stderr.writefln("Got text data: %s", data);
        }

        //~ enum PRINT_MODS = 1;
        enum PRINT_MODS = 0;

        static if (PRINT_MODS)
        {
            stderr.writefln("- Control: %s", event.keyMod & KeyMod.control);
            stderr.writefln("- Alt: %s", event.keyMod & KeyMod.alt);
            stderr.writefln("- Shift: %s", event.keyMod & KeyMod.shift);
            stderr.writefln("- LButton: %s", event.keyMod & KeyMod.mouse_left);
            stderr.writefln("- MButton: %s", event.keyMod & KeyMod.mouse_middle);
            stderr.writefln("- RButton: %s", event.keyMod & KeyMod.mouse_right);
        }

        stderr.writefln("Button 1 drag drop event: %s", event.action);
    };

    button2.onDragDropEvent ~= (scope DragDropEvent event)
    {
        // button1.dragDrop.unregister();
        stderr.writefln("Button 2 drag drop event: %s", event.action);
    };

    assert(!button1.dragDrop.isRegistered());

    button1.dragDrop.register();
    assert(button1.dragDrop.isRegistered());

    button1.dragDrop.unregister();
    assert(!button1.dragDrop.isRegistered());

    button1.dragDrop.register();
    assert(button1.dragDrop.isRegistered());

    button2.dragDrop.register();

    app.run();
}

void main()
{
}
