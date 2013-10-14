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
    testWindow.position = Point(400, 400);

    auto button1 = new Button(testWindow, "Button1");
    auto button2 = new Button(testWindow, "Button2");

    auto sourceLabel = new Label(testWindow);
    sourceLabel.text = "Source Ă text";

    auto label = new Label(testWindow);

    sourceLabel.grid
        .setRow(0).setCol(0).setColSpan(2);

    button1.grid
        .setRow(1).setCol(0);

    button2.grid
        .setRow(1).setCol(1);

    label.grid
        .setRow(2).setCol(0).setColSpan(2);

    button1.onDropEvent ~= (scope DropEvent event)
    {
        int x;
        assert(x);

        label.text = to!string(event.action);

        if (event.action == DropAction.leave)
            return;

        if (!event.hasData!string
            && !event.hasData!Widget)
            return;

        event.acceptDrop = true;

        if (event.action == DropAction.drop)
        {
            if (event.hasData!string)
            {
                string data;
                if (event.keyMod & (KeyMod.control + KeyMod.alt) && event.canMoveData)
                    data = event.moveData!string();
                else
                    data = event.copyData!string();

                stderr.writefln("Got text data: %s", data);
            }
            else
            if (event.hasData!Widget)
            {
                Widget data;
                if (event.keyMod & (KeyMod.control + KeyMod.alt) && event.canMoveData)
                    data = event.moveData!Widget();
                else
                    data = event.copyData!Widget();

                stderr.writefln("Got widget: %s", data);
            }
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

        //~ stderr.writefln("Button 1 drag drop event: %s", event.action);
    };

    button2.onDropEvent ~= (scope DropEvent event)
    {
        // button1.dragDrop.unregister();
        //~ stderr.writefln("Button 2 drag drop event: %s", event.action);
    };

    sourceLabel.onDragEvent ~= (scope DragEvent event)
    {
        if (event.action == DragAction.keyChange)
        {
            // if the escape key has been pressed, cancel the drop.
            if (event.escapePressed)
                event.cancel();

            // if the left mouse button has been released, do the drop.
            if (!event.keyMod.isDown(KeyMod.mouse_left))
                event.dropData();
        }
        else
        if (event.action == DragAction.feedback)
        {
            sourceLabel.text = "Feedback";
            // we've focused in/over/out of a widget
        }
        else
        if (event.action == DragAction.drop)
        {
            //~ if (event.hasMovedData)
                //~ sourceLabel.text = "Moved Data";
            //~ else
            //~ if (event.hasCopiedData)
                //~ sourceLabel.text = "Copied Data";
            //~ else
                //~ sourceLabel.text = "Data not moved/copied";
        }
        else
        if (event.action == DragAction.canceled)
        {
            //~ sourceLabel.text = "Drag & Drop canceled";
        }
    };

    sourceLabel.onMouseEvent ~= (scope MouseEvent event)
    {
        static MouseAction lastAction;
        static MouseButton lastButton;

        scope(exit) lastAction = event.action;
        scope(exit) lastButton = event.button;

        if (event.action == MouseAction.move && event.keyMod & KeyMod.mouse_left
            && lastAction == MouseAction.press && lastButton == MouseButton.left)
        {
            // text
            //~ DragData data = DragData(sourceLabel.text, CanMoveData.yes, CanCopyData.yes);

            // widget
            DragData data = DragData(sourceLabel, CanMoveData.yes, CanCopyData.yes);
            sourceLabel.startDragDrop(data);
        }
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
