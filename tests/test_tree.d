module test_tree;

import core.thread;

import std.conv;
import std.exception;
import std.range;
import std.stdio;
import std.string;

import dtk;
import dtk.tests.globals;

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 500, 200);
    testWindow.position = Point(500, 500);

    auto tree2 = new Tree(testWindow, "Directory", ["Filename", "Modified", "Created"]);

    auto tree = new Tree(testWindow, "Directory", ["Filename", "Modified", "Created"]);
    assert(tree.isRootTree);
    assert(tree.index == 0);

    assert(tree.getFocus is null);

    auto root1 = tree.add("Root 1");

    assert(tree.contains(root1));
    assert(!tree2.contains(root1));

    assert(!root1.isRootTree);
    assert(root1.parentTree is tree);
    assert(root1.parentTree.isRootTree);

    auto child1 = root1.add("Child 1");
    auto child2 = root1.add("Child 2");
    auto child4 = root1.insert(2, "Child 4");
    auto child3 = root1.insert(2, "Child 3");

    assert(child1.prevTree is null);
    assert(child2.prevTree is child1);
    assert(child3.prevTree is child2);
    assert(child4.prevTree is child3);

    assert(child1.nextTree is child2);
    assert(child2.nextTree is child3);
    assert(child3.nextTree is child4);
    assert(child4.nextTree is null);

    assert(child1.nextTree.prevTree is child1);

    auto ch1_1 = child1.add("Child 1.1");
    auto ch1_3 = child1.insert(1, "Child 1.3");
    auto ch1_2 = child1.insert(1, "Child 1.2");

    auto ch1_3_1 = ch1_3.add("Child 1.3.1");

    assert(child1.children == [ch1_1, ch1_2, ch1_3]);

    auto treeColOpts = ColumnOptions(Anchor.east, 100, DoStretch.yes, 100);
    tree.treeColumnOptions = treeColOpts;
    assert(tree.treeColumnOptions == treeColOpts);

    assert(tree.columnOptions(0).name == "Filename");
    assert(tree.columnOptions(1).name == "Modified");
    assert(tree.columnOptions(2).name == "Created");

    auto columnOpts = ColumnOptions(Anchor.east, 100, DoStretch.yes, 100);
    tree.setColumnOptions(0, columnOpts);
    assert(tree.columnOptions(0) == columnOpts, format("%s != %s", tree.columnOptions(0), columnOpts));

    assert(tree.treeColumnVisible);
    assert(tree.headingsVisible);

    tree.treeColumnVisible = false;
    assert(!tree.treeColumnVisible);
    assert(tree.headingsVisible);

    tree.treeColumnVisible = true;
    assert(tree.treeColumnVisible);
    assert(tree.headingsVisible);

    tree.headingsVisible = false;
    assert(tree.treeColumnVisible);
    assert(!tree.headingsVisible);

    tree.headingsVisible = true;
    assert(tree.treeColumnVisible);
    assert(tree.headingsVisible);

    assert(tree.selectMode == SelectMode.multiple);

    tree.selectMode = SelectMode.single;
    assert(tree.selectMode == SelectMode.single);

    assert(tree.visibleRows == 10);

    tree.visibleRows = 2;
    assert(tree.visibleRows == 2);

    tree.visibleRows = 10;
    assert(tree.visibleRows == 10);

    tree.displayColumns(1, 0);
    assert(tree.displayColumns() == [1, 0]);

    tree.displayColumns([0, 1]);
    assert(tree.displayColumns() == [0, 1]);

    tree.displayColumns([0, 2, 1]);
    assert(tree.displayColumns() == [0, 2, 1]);

    tree.displayAllColumns();
    assert(tree.displayColumns() == [0, 1, 2]);

    assert(root1.children.length == 4, root1.children.length.text);

    tree.destroy(child2);
    assert(root1.children.length == 3);

    auto parent = child1.parentTree;
    assert(parent is root1);

    child1.detach();
    assert(root1.children.length == 2);

    parent.attach(child1);
    assert(child1.index == 2, child1.index.text);
    assert(root1.children.length == 3);

    parent.attach(child1, 0);
    assert(child1.index == 0, child1.index.text);
    assert(root1.children.length == 3);

    child1.detach();
    child1.reattach();

    child1.setFocus();
    assert(tree.getFocus is child1);

    assert(tree.headingOptions(0).text == "Filename");
    assert(tree.headingOptions(1).text == "Modified");

    auto headOpts = HeadingOptions("Dirname", Anchor.center);
    tree.setHeadingOptions(0, headOpts);
    assert(tree.headingOptions(0) == headOpts);

    assert(tree.treeHeadingOptions.text == "Directory");

    auto treeHeadOpts = HeadingOptions("Tree Dir", Anchor.center);
    tree.treeHeadingOptions = treeHeadOpts;
    assert(tree.treeHeadingOptions == treeHeadOpts, format("%s != %s", tree.treeHeadingOptions, treeHeadOpts));

    auto rowOpts1 = RowOptions("Child 1", NoImage, ["2012-04-05", "2012-01-01"], IsOpened.yes);
    child1.rowOptions = rowOpts1;
    assert(child1.rowOptions == rowOpts1);

    root1.rowOptions = RowOptions("Root 1", NoImage, [], IsOpened.yes);

    ch1_3_1.setVisible();

    assert(tree.selection is null);

    tree.selection = [child1, ch1_3_1];
    assert(tree.selection == [child1, ch1_3_1]);

    tree.selection = child1;
    assert(tree.selection == [child1]);

    tree.deselectAll();
    assert(tree.selection is null);

    tree.addSelection(child1);
    assert(tree.selection == [child1]);

    tree.addSelection(ch1_3_1);
    assert(tree.selection == [child1, ch1_3_1]);

    tree.toggleSelection(child1);
    assert(tree.selection == [ch1_3_1]);

    tree.toggleSelection(child1);
    assert(tree.selection == [child1, ch1_3_1]);

    ch1_3_1.setColumn(0, "Foo Dir");
    ch1_3_1.setColumn(1, "Modified Date");
    ch1_3_1.setColumn(2, "Created Date");

    ch1_3_1.setColumn(2, `" Test [ String { $ # Stuff `);
    ch1_3_1.setColumn(2, "Created Date");

    tree.pack();

    app.run();
}

void main()
{
}
