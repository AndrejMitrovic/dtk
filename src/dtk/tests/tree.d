/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.tree;

version(unittest):
version(DTK_UNITTEST):

import dtk;
import dtk.imports;
import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 500, 200);
    testWindow.position = Point(500, 500);

    auto image = new Image("../tests/disk_blue.png");

    auto tree = new Tree(testWindow, "Heading");

    auto child1 = tree.add();

    tree.setHeadings(["Heading 0", "Heading 1", "Heading 2"]);

    /* root header options. */

    assert(child1.heading.text == "Heading");
    child1.heading.text = "Tree Name";
    assert(child1.heading.text == "Tree Name");

    child1.heading.anchor = Anchor.center;
    assert(child1.heading.anchor == Anchor.center);

    static assert(!is(typeof({
        child1.heading.minWidth = 100;
        assert(child1.heading.minWidth == 100);
    })));

    static assert(!is(typeof({
        child1.heading.width = 100;
        assert(child1.heading.width == 100);
    })));

    child1.heading.image = image;
    assert(child1.heading.image is image);

    /* header options. */

    assert(child1.headings[0].text == "Heading 0");

    child1.headings[0].text = "Tree Value";
    assert(child1.headings[0].text == "Tree Value");

    child1.headings[0].anchor = Anchor.center;
    assert(child1.headings[0].anchor == Anchor.center);

    static assert(!is(typeof({
        child1.headings[0].minWidth = 100;
        assert(child1.headings[0].minWidth == 100);
    })));

    static assert(!is(typeof({
        child1.headings[0].width = 100;
        assert(child1.headings[0].width == 100);
    })));

    child1.headings[0].image = image;
    assert(child1.headings[0].image is image);

    /* root column options. */

    child1.column.text = "First Tree";
    assert(child1.column.text == "First Tree", child1.column.text);

    child1.column.anchor = Anchor.center;
    assert(child1.column.anchor == Anchor.center);

    child1.column.minWidth = 100;
    assert(child1.column.minWidth == 100);

    child1.column.width = 100;
    assert(child1.column.width == 100);

    child1.column.image = image;
    assert(child1.column.image is image);

    child1.column.stretch = true;
    assert(child1.column.stretch == true);

    /* column options. */

    child1.columns[0].text = "First Value";
    assert(child1.columns[0].text == "First Value");

    child1.columns[0].anchor = Anchor.center;
    assert(child1.columns[0].anchor == Anchor.center);

    child1.columns[0].minWidth = 100;
    assert(child1.columns[0].minWidth == 100);

    child1.columns[0].width = 100;
    assert(child1.columns[0].width == 100);

    static assert(!is(typeof({
        child1.columns[0].image = image;
        assert(child1.columns[0].image is image);
    })));

    child1.columns[0].stretch = true;
    assert(child1.columns[0].stretch == true);

    /* column values. */
    child1.values = ["First Value", "Second Value", "Third Value"];
    assert(child1.values == ["First Value", "Second Value", "Third Value"]);

    /* column tags. */
    child1.tags = ["tag1", "tag2"];
    assert(child1.tags == ["tag1", "tag2"]);

    /* open. */
    child1.isOpened = true;
    assert(child1.isOpened);

    child1.isOpened = false;
    assert(!child1.isOpened);

    assert(tree.isRootTree);
    assert(tree.index == 0);

    assert(tree.getFocusedTree is null);

    auto root1 = tree.add("Root 1");
    assert(tree.contains(root1));

    auto tree1 = tree.add("Tree 123");
    assert(tree.contains(root1));

    assert(!root1.isRootTree);
    assert(root1.parentTree is tree);
    assert(root1.parentTree.isRootTree);

    child1 = root1.add("Child 1");
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

    /* test tree column options. */
    tree.column.text = "Root tree";
    assert(tree.column.text == "Root tree");

    tree.column.anchor = Anchor.e;
    assert(tree.column.anchor == Anchor.e);

    tree.column.minWidth = 100;
    assert(tree.column.minWidth == 100);

    tree.column.width = 100;
    assert(tree.column.width == 100);

    tree.column.stretch = true;
    assert(tree.column.stretch == true);

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

    child2.destroy();
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
    assert(tree.getFocusedTree is child1);

    root1.column.text = "Root 1";

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

    ch1_3_1.columns[0].text = "Foo Dir";
    ch1_3_1.columns[1].text = "Modified Date";
    ch1_3_1.columns[2].text = `" Test [ String { $ # Stuff `;

    tree.pack();

    app.testRun();
}
