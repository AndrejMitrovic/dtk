module test_layout;

import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import std.traits;
import std.typetuple;

import dtk;

void main()
{
    auto app = new App;

    auto testWindow = app.mainWindow;
    testWindow.position = Point(500, 400);
    testWindow.size = Size(300, 300);

    testWindow.onKeyboardEvent ~= (scope KeyboardEvent e)
    {
        if (e.keySym == KeySym.Escape)
            testWindow.destroy();
    };

    auto frame = new Frame(testWindow);
    frame.borderStyle = BorderStyle.raised;
    frame.borderWidth = 2;

    frame.grid.setRow(0).setCol(0);

    //~ testWindow.grid.colOptions(0).weight = 1;
    //~ testWindow.grid.rowOptions(0).weight = 1;

    frame.grid.anchor = Anchor.center;
    frame.grid.sticky = Sticky.nsew;

    string text = "First line.\nSecond line.";

    auto label1 = new Label(frame, text);
    label1.grid.setRow(0).setCol(0);
    label1.fgColor = RGB(255, 0, 0);

    auto label2 = new Label(frame, text);
    label2.grid.setRow(0).setCol(1);
    label2.fgColor = RGB(255, 255, 0);

    auto label3 = new Label(frame, text);
    label3.grid.setRow(1).setCol(0);
    label3.fgColor = RGB(0, 0, 255);

    auto label4 = new Label(frame, text);
    label4.grid.setRow(1).setCol(1);
    label4.fgColor = RGB(0, 255, 64);

    //~ button1.onButtonEvent ~= ()
    //~ {
        //~ with (frame.grid)
        //~ {
            //~ stderr.writeln(boundBox());
            //~ stderr.writeln(boundBox(0, 0));
            //~ stderr.writeln(boundBox(0, 0, 1, 1));
            //~ stderr.writeln(boundBox(1, 1, 2, 2));

            //~ anchor = Anchor.n;
            //~ assert(anchor == Anchor.n);

            //~ // this will make the main window not resize itself
            //~ propagate = false;
            //~ assert(propagate == false);

            //~ propagate = true;

            //~ assert(size == GridSize(1, 3), size.text);

            //~ assert(slaves.length == 3);
            //~ assert(walkSlaves.walkLength == 3);

            //~ assert(rowSlaves(0).length == 3);
            //~ assert(walkRowSlaves(0).walkLength == 3);

            //~ assert(rowSlaves(1).length == 0);
            //~ assert(walkRowSlaves(1).walkLength == 0);

            //~ assert(colSlaves(0).length == 1);
            //~ assert(walkColSlaves(0).walkLength == 1);

            //~ assert(colSlaves(1).length == 1);
            //~ assert(walkColSlaves(1).walkLength == 1);

            //~ assert(colSlaves(2).length == 1);
            //~ assert(walkColSlaves(2).walkLength == 1);

            //~ assert(colSlaves(3).length == 0);
            //~ assert(walkColSlaves(3).walkLength == 0);

            //~ assert(location(Point(0, 0)) == GridCell(0, 0));
            //~ assert(location(Point(100, 100)) == GridCell(1, 1), location(Point(100, 100)).text);
        //~ }

        //~ button1.grid
            //~ .setRow(1)
            //~ .setCol(1)
            //~ .setRowSpan(1)
            //~ .setColSpan(2)
            //~ .setInterPadX(2)
            //~ .setInterPadY(2)
            //~ .setPadX(4)
            //~ .setPadY(8)
            //~ .setSticky(Sticky.ns);

        //~ // note: grid manager doesn't have introspection to retrieve these values
        //~ /+ with (button1.grid)
        //~ {
            //~ assert(row == 1);
            //~ assert(col == 1);
            //~ assert(rowSpan == 1);
            //~ assert(colSpan == 1);
            //~ assert(interPadX == 2);
            //~ assert(interPadY == 2);
            //~ assert(padX == 4);
            //~ assert(padY == 8);
            //~ assert(sticky == Sticky.ns);
        //~ } +/

        //~ with (button1.grid)
        //~ {
            //~ // note: grid manager doesn't have introspection to retrieve these values

            //~ row = 1;
            //~ // assert(row == 1);

            //~ col = 1;
            //~ // assert(col == 1);

            //~ rowSpan = 1;
            //~ // assert(rowSpan == 1);

            //~ colSpan = 1;
            //~ // assert(colSpan == 1);

            //~ interPadX = 2;
            //~ // assert(interPadX == 2);

            //~ interPadY = 2;
            //~ // assert(interPadY == 2);

            //~ padX = 4;
            //~ // assert(padX == 4);

            //~ padY = 8;
            //~ // assert(padY == 8);

            //~ sticky = Sticky.ns;
            //~ // assert(sticky == Sticky.ns);
        //~ }

        //~ button1.grid.remove();
        //~ button1.grid.reset();

        //~ button2.grid
            //~ .setRow(0)
            //~ .setCol(0)
            //~ .setRowSpan(1)
            //~ .setColSpan(1)
            //~ .setInterPadX(2)
            //~ .setInterPadY(2)
            //~ .setPadX(4)
            //~ .setPadY(8)
            //~ .setSticky(Sticky.ns);

        //~ button3.grid.forget();
        //~ button3.grid.reset();

        //~ frame.grid.colOptions(1)
            //~ .setMinSize(5)
            //~ .setWeight(5)
            //~ .setUniform("foo")
            //~ .setPad(5);

        //~ with (frame.grid.colOptions(1))
        //~ {
            //~ assert(minSize == 5);
            //~ assert(weight == 5);
            //~ assert(uniform == "foo");
            //~ assert(pad == 5);
        //~ }

        //~ with (frame.grid.colOptions(1))
        //~ {
            //~ minSize = 10;
            //~ assert(minSize == 10);

            //~ weight = 10;
            //~ assert(weight == 10);

            //~ uniform = "foo bar";
            //~ assert(uniform == "foo bar");

            //~ pad = 10;
            //~ assert(pad == 10);
        //~ }

        //~ with (frame.grid.rowOptions(1))
        //~ {
            //~ minSize = 10;
            //~ assert(minSize == 10);

            //~ weight = 10;
            //~ assert(weight == 10);

            //~ uniform = "foo bar";
            //~ assert(uniform == "foo bar");

            //~ pad = 10;
            //~ assert(pad == 10);
        //~ }
    //~ };

    //~ button1.push();

    app.run();
}
