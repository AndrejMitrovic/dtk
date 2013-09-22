/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.tree;

import std.algorithm;
import std.array;
import std.exception;
import std.range;

import dtk.geometry;
import dtk.image;
import dtk.interpreter;
import dtk.types;
import dtk.utils;

import dtk.widgets.options;
import dtk.widgets.widget;

///
enum IsOpened
{
    no,
    yes,
}

///
enum DoStretch
{
    no,
    yes,
}

///
struct HeadingOption
{
    private this(Tree tree, string tkTag, string index)
    {
        _tree = tree;
        _tkTag = tkTag;
        _index = index;
    }

    private this(Tree tree, string tkTag, int index)
    {
        this(tree, tkTag, to!string(index));
    }

    /** Get the tree name. */
    @property string text()
    {
        return tclEvalFmt("%s %s %s -text", _tree._name, _tkTag, _index);
    }

    /** Set a new tree text. */
    @property void text(string newName)
    {
        tclEvalFmt("%s %s %s -text %s", _tree._name, _tkTag, _index, newName._tclEscape);
    }

    /** Get the current anchor for the column of the tree name display. */
    @property Anchor anchor()
    {
        return tclEvalFmt("%s %s %s -anchor", _tree._name, _tkTag, _index).toAnchor();
    }

    /** Set a new anchor for the column of the tree name display. */
    @property void anchor(Anchor newAnchor)
    {
        tclEvalFmt("%s %s %s -anchor %s", _tree._name, _tkTag, _index, newAnchor.toString());
    }

    ///
    @property Image image()
    {
        string imagePath = tclEvalFmt("%s %s %s -image", _tree._name, _tkTag, _index);
        return cast(Image)Widget.lookupWidgetPath(imagePath);
    }

    ///
    @property void image(Image newImage)
    {
        tclEvalFmt("%s %s %s -image %s", _tree._name, _tkTag, _index, newImage ? newImage._name : "{}");
    }

private:
    Tree _tree;
    string _tkTag;
    string _index;
}

///
struct HeadingOptions
{
    mixin ItemOptions!HeadingOption;
}

///
struct RootColumnOption
{
    private this(Tree tree, string tkTag, string index)
    {
        _tree = tree;
        _tkTag = tkTag;
        _index = index;
    }

    private this(Tree tree, string tkTag, int index)
    {
        this(tree, tkTag, to!string(index));
    }

    // avoid std.conv.text hijacking
    @disable int text;

    /** Get the current anchor for the column of the tree name display. */
    @property Anchor anchor()
    {
        return tclEvalFmt("%s %s %s -anchor", _tree._name, _tkTag, _index).toAnchor();
    }

    /** Set a new anchor for the column of the tree name display. */
    @property void anchor(Anchor newAnchor)
    {
        tclEvalFmt("%s %s %s -anchor %s", _tree._name, _tkTag, _index, newAnchor.toString());
    }

    ///
    @property int minWidth()
    {
        return tclEvalFmt("%s %s %s -minwidth", _tree._name, _tkTag, _index).to!int;
    }

    ///
    @property void minWidth(int newMinWidth)
    {
        tclEvalFmt("%s %s %s -minwidth %s", _tree._name, _tkTag, _index, newMinWidth);
    }
       ///
    @property int width()
    {
        return tclEvalFmt("%s %s %s -width", _tree._name, _tkTag, _index).to!int;
    }

    ///
    @property void width(int newWidth)
    {
        tclEvalFmt("%s %s %s -width %s", _tree._name, _tkTag, _index, newWidth);
    }

    ///
    @property bool stretch()
    {
        return cast(bool)tclEvalFmt("%s %s %s -stretch", _tree._name, _tkTag, _index).to!int;
    }

    ///
    @property void stretch(bool doStretch)
    {
        tclEvalFmt("%s %s %s -stretch %s", _tree._name, _tkTag, _index, cast(int)doStretch);
    }

private:
    Tree _tree;
    string _tkTag;
    string _index;
}

///
struct ColumnOption
{
    private this(Tree tree, string tkTag, string index)
    {
        _tree = tree;
        _tkTag = tkTag;
        _index = index;
    }

    private this(Tree tree, string tkTag, int index)
    {
        this(tree, tkTag, to!string(index));
    }

    ///
    @property string text()
    {
        return tclEvalFmt("%s set %s %s", _tree._name, _tree._treeID, _index);
    }

    @property void text(string newValue)
    {
        tclEvalFmt("%s set %s %s %s", _tree._name, _tree._treeID, _index, newValue._tclEscape);
    }

    /** Get the current anchor for the column of the tree name display. */
    @property Anchor anchor()
    {
        return tclEvalFmt("%s %s %s -anchor", _tree._name, _tkTag, _index).toAnchor();
    }

    /** Set a new anchor for the column of the tree name display. */
    @property void anchor(Anchor newAnchor)
    {
        tclEvalFmt("%s %s %s -anchor %s", _tree._name, _tkTag, _index, newAnchor.toString());
    }

    ///
    @property int minWidth()
    {
        return tclEvalFmt("%s %s %s -minwidth", _tree._name, _tkTag, _index).to!int;
    }

    ///
    @property void minWidth(int newMinWidth)
    {
        tclEvalFmt("%s %s %s -minwidth %s", _tree._name, _tkTag, _index, newMinWidth);
    }
       ///
    @property int width()
    {
        return tclEvalFmt("%s %s %s -width", _tree._name, _tkTag, _index).to!int;
    }

    ///
    @property void width(int newWidth)
    {
        tclEvalFmt("%s %s %s -width %s", _tree._name, _tkTag, _index, newWidth);
    }

    ///
    @property bool stretch()
    {
        return cast(bool)tclEvalFmt("%s %s %s -stretch", _tree._name, _tkTag, _index).to!int;
    }

    ///
    @property void stretch(bool doStretch)
    {
        tclEvalFmt("%s %s %s -stretch %s", _tree._name, _tkTag, _index, cast(int)doStretch);
    }

private:
    Tree _tree;
    string _tkTag;
    string _index;
}

///
struct ColumnOptions
{
    mixin ItemOptions!ColumnOption;
}

mixin template ItemOptions(Type)
{
    this(Tree tree, string tkTag)
    {
        _tree = tree;
        _tkTag = tkTag;
    }

    ///
    Type opIndex(int index)
    {
        return typeof(return)(_tree, _tkTag, index);
    }

    ///
    void opIndexAssign(int index, Type newOption)
    {
        auto option = Type(_tree, _tkTag, index);
        option = newOption;
    }

private:
    Tree _tree;
    string _tkTag;
}

///
class Tree : Widget
{
    ///
    this(Widget master, string label = null, string[] columns = null)
    {
        super(master, TkType.tree, WidgetType.tree);

        if (!label.empty)
            heading.text = label;

        this.setColumns(columns);
        _rootTree = this;
        _treeIDMap[_rootTreeID] = this;
    }

    /**
        name is the name of the root Tk tree widget.
        treeIdent is used in add and insert calls.
    */
    private this(Tree rootTree, string name, string treeIdent)
    {
        super(CreateFakeWidget.init, WidgetType.tree);
        _treeID = treeIdent;
        _name = name;
        _rootTree = rootTree;
        _rootTree._treeIDMap[treeIdent] = this;
    }

    // set the columns
    void setColumns(string[] columns)
    {
        if (columns.empty)
            return;

        // create the columns
        tclEvalFmt("%s configure -columns { %s }", _name, map!_tclEscape(columns).join(" "));

        // set the column names
        foreach (idx, col; columns)
            tclEvalFmt(`%s heading %s -text %s`, _name, idx, col._tclEscape);

        _columnIndexes = cast(int[])iota(0, columns.length).array;
    }

    /**
        Add an item to this tree.

        Returns the tree of the item to be added.
        This tree is needed if you want to add a child item
        to this tree.
    */
    // todo: handle all arguments
    Tree addChild(string text = null, Image image = null, IsOpened isOpened = IsOpened.no, string[] values = null, string[] tags = null)
    {
        return new Tree(_rootTree, _name, tclEvalFmt("%s insert %s end -text %s", _name, _treeID, text._tclEscape));
    }

    /**
        Add an item to this tree at a specific index.

        Returns the tree of the item to be added.
        This tree is needed if you want to add a child item
        to this tree.
    */
    // todo: handle all arguments
    Tree insertChild(int index, string text = null, Image image = null, IsOpened isOpened = IsOpened.no, string[] values = null, string[] tags = null)
    {
        return new Tree(_rootTree, _name, tclEvalFmt("%s insert %s %s -text %s", _name, _treeID, index, text._tclEscape));
    }

    /** Return the index of this tree. */
    int index()
    {
        return tclEvalFmt("%s index %s", _name, _treeID).to!int;
    }

    /** Attach a tree to this tree at the last position. */
    void attach(Tree tree)
    {
        tclEvalFmt("%s move %s %s end", _name, tree._treeID, _treeID);
    }

    /** Attach a tree to this tree at a specific position. */
    void attach(Tree tree, int index)
    {
        tclEvalFmt("%s move %s %s %s", _name, tree._treeID, _treeID, index);
    }

    /**
        Detach this tree by hiding it. This does not destroy the tree.
        The tree can be re-attached to its original position by calling
        the $(D reattach) method. Alternatively it can be re-attached
        to an arbitrary position with the $(D attach) method.
    */
    void detach()
    {
        // note: this call must come before calling detach or .parentTree will return the root identifier
        _detachInfo = DetachInfo(parentTree, index, IsDetached.yes);
        tclEvalFmt("%s detach %s", _name, _treeID);
    }

    /**
        Reattach this tree back to its original position.
        If the tree was not detached, the function returns early.

        If the parent tree no longer exists, an exception is thrown.
        If the index is out of bounds, the tree will be attached
        to the last position.
    */
    void reattach()
    {
        // no need to attach
        if (_detachInfo.isDetached == IsDetached.no)
            return;

        enforce(!_detachInfo.parentTree._isDestroyed,
            "Cannot reattach tree because its parent tree was destroyed.");

        // todo: provide a better implementation
        auto treeCount = tclEvalFmt("%s children %s", _name, _detachInfo.parentTree._treeID).splitter(" ").walkLength;

        // readjust index if it's out of bounds
        if (_detachInfo.index >= treeCount)
            _detachInfo.index = treeCount - 1;

        _detachInfo.parentTree.attach(this, _detachInfo.index);
        _detachInfo.isDetached = IsDetached.no;
    }

    ///
    alias super.destroy destroy;

    /** Remove and destroy a tree. */
    void destroy(Tree tree)
    {
        enforce(tree._treeID in _rootTree._treeIDMap,
            format("Cannot destroy tree which is not part of the root tree of this tree."));

        enforce(tree._treeID != _rootTreeID,
            format("Cannot destroy root tree."));

        tree._isDestroyed = true;

        _rootTree._treeIDMap.remove(tree._treeID);

        tclEvalFmt("%s delete %s", _name, tree._treeID);
    }

    /** Return the parent tree of this tree, or null if this is the root tree. */
    @property Tree parentTree()
    {
        if (this.isRootTree)
            return null;

        string parentID = tclEvalFmt("%s parent %s", _name, _treeID);

        if (parentID.empty)  // nested right in the root tree
            return _rootTree;

        enforce(parentID in _rootTree._treeIDMap,
            format("Can't find: %s", parentID));

        auto parent = _rootTree._treeIDMap[parentID];

        enforce(!parent._isDestroyed,
            "Cannot return parent tree because it was destroyed.");

        return parent;
    }

    /** Return the previous sibling tree, or null if this is the first child of its parent tree. */
    Tree prevTree()
    {
        string prevID = tclEvalFmt("%s prev %s", _name, _treeID);

        if (prevID.empty)
            return null;

        enforce(prevID in _rootTree._treeIDMap,
            format("Cannot return previous tree because it was destroyed."));

        return _rootTree._treeIDMap[prevID];
    }

    /** Return the next sibling tree, or null if this is the last child of its parent tree. */
    Tree nextTree()
    {
        string nextID = tclEvalFmt("%s next %s", _name, _treeID);

        if (nextID.empty)
            return null;

        enforce(nextID in _rootTree._treeIDMap,
            format("Cannot return next tree because it was destroyed."));

        return _rootTree._treeIDMap[nextID];
    }

    /** Get the selected trees. */
    @property Tree[] selection()
    {
        string treeIDs = tclEvalFmt("%s selection", _name);

        Appender!(Tree[]) result;

        foreach (treeID; treeIDs.splitter(" "))
        {
            enforce(treeID in _rootTree._treeIDMap,
                format("Cannot return selected tree because it was destroyed."));

            auto tree = _rootTree._treeIDMap[treeID];
            if (tree !is null)
                result ~= tree;
        }

        if (result.data.empty)
            return null;

        return result.data;
    }

    /** Select a single tree. */
    @property void selection(Tree tree)
    {
        enforce(tree._treeID in _rootTree._treeIDMap,
            format("Cannot select tree because it is not part of this root tree."));

        tclEvalFmt("%s selection set %s", _name, tree._treeID);
    }

    /** Select multiple trees. */
    @property void selection(Tree[] trees)
    {
        foreach (tree; trees)
        {
            enforce(tree._treeID in _rootTree._treeIDMap,
                format("Cannot select tree because it is not part of this root tree."));
        }

        tclEvalFmt("%s selection set [list %s]", _name, trees.map!(a => a._treeID).join(" "));
    }

    /** Add one or more trees to the selection. */
    void addSelection(Tree[] trees...)
    {
        foreach (tree; trees)
        {
            enforce(tree._treeID in _rootTree._treeIDMap,
                format("Cannot add tree to selection because it is not part of this root tree."));
        }

        tclEvalFmt("%s selection add [list %s]", _name, trees.map!(a => a._treeID).join(" "));
    }

    /** Toggle the select state of one or more trees. */
    void toggleSelection(Tree[] trees...)
    {
        foreach (tree; trees)
        {
            enforce(tree._treeID in _rootTree._treeIDMap,
                format("Cannot toggle selection of tree because it is not part of this root tree."));
        }

        tclEvalFmt("%s selection toggle [list %s]", _name, trees.map!(a => a._treeID).join(" "));
    }

    /** Remove all selections from this tree. */
    void deselectAll()
    {
        string treeIDs = tclEvalFmt("%s selection", _name);
        foreach (treeID; treeIDs.splitter(" "))
            tclEvalFmt("%s selection remove %s", _name, treeID);
    }

    /**
        Set this tree so it's visible. This opens all of this tree's ancestors,
        and potentially scrolls the widget so this tree is visible to the user.
    */
    void setVisible()
    {
        tclEvalFmt("%s see %s", _name, _treeID);
    }

    /** Check if this tree is the root tree. */
    @property bool isRootTree()
    {
        return _treeID == _rootTreeID;
    }

    /**
        Check if a tree is present in the entire tree structure that
        this tree belongs to, anywhere from this tree's root tree
        through all of its descendants.

        If you only want to check if a tree is a direct child of this tree,
        use $(D targetTree.parentTree is containerTree).
    */
    @property bool contains(Tree tree)
    {
        return tclEvalFmt("%s exists %s", _name, tree._treeID) == "1";
    }

    /** Return the children of this tree. */
    @property Tree[] children()
    {
        Appender!(Tree[]) result;

        string treePaths = tclEvalFmt("%s children %s", _name, _treeID);

        foreach (treePath; treePaths.splitter(" "))
        {
            enforce(treePath in _rootTree._treeIDMap, format("%s not in %s", treePath, _rootTree._treeIDMap));

            auto tree = _rootTree._treeIDMap[treePath];
            if (tree !is null)
                result ~= tree;
        }

        return result.data;
    }

    /**
        Get the current focused tree.
        If no tree is in focus, returns null.
    */
    Tree getFocusedTree()
    {
        string treePath = tclEvalFmt("%s focus", _name);

        if (treePath.empty)
            return null;

        enforce(treePath in _rootTree._treeIDMap,
            format("%s not in %s", treePath, _rootTree._treeIDMap));

        return _rootTree._treeIDMap[treePath];
    }

    /** Set this tree to be the focused tree. */
    void setFocus()
    {
        tclEvalFmt("%s focus %s", _name, _treeID);
    }

    /** Get the tree column visibility. */
    @property bool treeColumnVisible()
    {
        string res = this.getOption!string("show");

        foreach (item; res.splitter(" "))
        {
            if (item == "tree")
                return true;
        }

        return false;
    }

    /** Set the tree column visibility. */
    @property void treeColumnVisible(bool isVisible)
    {
        string showOpt = format("%s %s",
                             isVisible ? "tree" : "",
                             this.headingsVisible ? "headings" : "");

        this.setOption("show", showOpt);
    }

    /** Get the headings visibility. */
    @property bool headingsVisible()
    {
        string res = this.getOption!string("show");

        foreach (item; res.splitter(" "))
        {
            if (item == "headings")
                return true;
        }

        return false;
    }

    /** Set the headings visibility. */
    @property void headingsVisible(bool isVisible)
    {
        string showOpt = format("%s %s",
                             this.treeColumnVisible ? "tree" : "",
                             isVisible ? "headings" : "");

        this.setOption("show", showOpt);
    }

    /** Get the current selection mode. */
    @property SelectMode selectMode()
    {
        return this.getOption!string("selectmode").toSelectMode();
    }

    /** Set the selection mode. */
    @property void selectMode(SelectMode newSelectMode)
    {
        this.setOption("selectmode", newSelectMode.toString());
    }

    /** Return the number of rows which are set to be visible. */
    @property int visibleRows()
    {
        return this.getOption!int("height");
    }

    /**
        Set the number of rows which should be visible.
        The user can still scroll through all the rows, but only
        this count of rows will be visible at once in the screen.
    */
    @property void visibleRows(int rowCount)
    {
        this.setOption("height", rowCount);
    }

    /** Get the current padding that's included inside the border. */
    @property Padding padding()
    {
        return this.getOption!string("padding").toPadding;
    }

    /** Set the padding that's included inside the border. */
    @property void padding(Padding newPadding)
    {
        this.setOption("padding", newPadding.toString);
    }

    //~ /** Get the options for the row this tree belongs to. */
    //~ @property RowOptions rowOptions()
    //~ {
        //~ RowOptions options;

        //~ options.text = tclEvalFmt("%s item %s -text", _name, _treeID);

        //~ string imagePath = tclEvalFmt("%s item %s -image", _name, _treeID);
        //~ options.image = cast(Image)Widget.lookupWidgetPath(imagePath);

        //~ options.values = tclEvalFmt("%s item %s -values", _name, _treeID).split;

        //~ string isOpenStr = tclEvalFmt("%s item %s -open", _name, _treeID);
        //~ options.isOpened = (isOpenStr == "1" || isOpenStr == "true") ? IsOpened.yes : IsOpened.no;

        //~ options.tags = tclEvalFmt("%s item %s -tags", _name, _treeID).split;

        //~ return options;
    //~ }

    //~ /** Set the options for the row this tree belongs to. */
    //~ @property void rowOptions(RowOptions options)
    //~ {
        //~ tclEvalFmt("%s item %s -text %s", _name, _treeID, options.text._tclEscape);
        //~ tclEvalFmt("%s item %s -values [list %s]", _name, _treeID, options.values.join(" "));
        //~ tclEvalFmt("%s item %s -open %s", _name, _treeID, cast(int)options.isOpened);
        //~ tclEvalFmt("%s item %s -tags [list %s]", _name, _treeID, options.tags.join(" "));
        //~ tclEvalFmt("%s item %s -image %s", _name, _treeID, options.image ? options.image._name : "{}");
    //~ }

    /** Return the set of columns which are displayed. */
    int[] displayColumns()
    {
        string str = this.getOption!string("displaycolumns");

        if (str == "#all")
        {
            return _rootTree._columnIndexes;
        }

        str = str.chomp("]").chompPrefix("[");

        Appender!(int[]) result;

        foreach (item; str.splitter(" "))
            result ~= to!int(item);

        return result.data;
    }

    /**
        Set a specific set of columns which should be visible,
        in the order that they're listed in the arguments.

        For example, to display the columns 0, 2, and 4, but
        in reverse order, call $(D displayColumns(4, 2, 0)).
    */
    void displayColumns(int[] columns...)
    {
        this.setOption("displaycolumns", map!(to!string)(columns).join(" "));
    }

    /** Set all columns to be visible. */
    void displayAllColumns()
    {
        this.setOption("displaycolumns", "#all");
    }

    ///
    @property HeadingOptions headings()
    {
        return typeof(return)(this, "heading");
    }

    ///
    @property HeadingOption heading()
    {
        return typeof(return)(this, "heading", "#0");
    }

    ///
    @property ColumnOptions columns()
    {
        return typeof(return)(this, "column");
    }

    ///
    @property RootColumnOption column()
    {
        return typeof(return)(this, "column", "#0");
    }

    ///
    override string toString() const
    {
        string text = tclEvalFmt("%s item %s -text", _name, _treeID);
        return format("%s(%s)", typeof(this).stringof, text);
    }

private:
    enum string _rootTreeID = "{}";

    string _treeID = _rootTreeID;
    Tree _rootTree;  // required to look up the tree list

    /**
        Initialized in root tree, required to look up
        Tree D class instances in call to children.
    */
    Tree[string] _treeIDMap;

    /**
        Initialized in root tree,
        required to get visible columns.
    */
    int[] _columnIndexes;

    enum IsDetached { no, yes }

    /**
        Note: parentTree and index are only kept up to date in the last detach
        call. Only use these in the reattach call, when isDetached
        equals IsDetached.yes.
    */
    static struct DetachInfo
    {
        Tree parentTree;
        int index;
        IsDetached isDetached;
    }

    /**
        When a tree is detached, it loses its parent tree and index information.
        We have to store this before detaching so we can re-attach back
        to its original place when reattach is called.
    */
    DetachInfo _detachInfo;
}
