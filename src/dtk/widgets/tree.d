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
import std.string;

import dtk.geometry;
import dtk.image;
import dtk.interpreter;
import dtk.utils;

import dtk.widgets.options;
import dtk.widgets.widget;

///
enum Image NoImage = null;

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
struct RowOptions
{
    string text;
    Image image;
    string[] values;
    IsOpened isOpened;
    string[] tags;
}

///
struct ColumnOptions
{
    /**
        Note: Required due to allowed writing to inaccessible
        fields via field initialization:
        http://d.puremagic.com/issues/show_bug.cgi?id=10861
    */
    this(Anchor anchor, int minWidth, DoStretch doStretch, int width)
    {
        _anchor = anchor;
        _minWidth = minWidth;
        _doStretch = doStretch;
        _width = width;
        _userInited = true;
    }

    /**
        Read-only column name.
        Only valid if it was returned from a dtk call.
    */
    @property string name()
    {
        return _name;
    }

    ///
    string toString() const
    {
        return format("%s(%s, %s, %s, %s, %s)",
            typeof(this).stringof, _name, _anchor, _minWidth, _doStretch, _width);
    }

    bool opEquals(ColumnOptions rhs)
    {
        // if either options were user-initialized, don't compare names, since
        // names are exclusively retrieved from Tk and never set by the user.
        bool namesEqual = (_userInited || rhs._userInited);
        if (!namesEqual)
            namesEqual = _name == rhs.name;

        return namesEqual &&
            _anchor == rhs._anchor &&
            _minWidth == rhs._minWidth &&
            _doStretch == rhs._doStretch &&
            _width == rhs._width;
    }

private:
    string _name;
    Anchor _anchor;
    int _minWidth;
    DoStretch _doStretch;
    int _width;
    bool _userInited;
}

///
struct HeadingOptions
{
    string text;
    Anchor anchor;
    Image image;

    private void* command;  // do not use yet
}

///
class Tree : Widget
{
    ///
    this(Widget master, string label, string[] columns)
    {
        super(master, TkType.tree);

        // create the columns
        tclEvalFmt("%s configure -columns %s", _name, columns.join(" ")._tclEscape);

        // set the tree column label
        tclEvalFmt(`%s heading #0 -text %s`, _name, label._tclEscape);

        // set the column names
        foreach (idx, col; columns)
            tclEvalFmt(`%s heading %s -text %s`, _name, idx, col._tclEscape);

        _rootTree = this;
        _treeIDMap[_rootTreeID] = this;

        _columnIndexes = cast(int[])iota(0, columns.length).array;
    }

    /**
        name is the name of the root Tk tree widget.
        treeIdent is used in add and insert calls.
    */
    private this(Tree rootTree, string name, string treeIdent)
    {
        super(CreateFakeWidget.init);
        _treeID = treeIdent;
        _name = name;
        _rootTree = rootTree;
        _rootTree._treeIDMap[treeIdent] = this;
    }

    /**
        Add an item to this tree.

        Returns the tree of the item to be added.
        This tree is needed if you want to add a child item
        to this tree.
    */
    // todo: handle all arguments
    Tree add(string text, Image image = null, IsOpened isOpened = IsOpened.no, string[] values = null, string[] tags = null)
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
    Tree insert(int index, string text, Image image = null, IsOpened isOpened = IsOpened.no, string[] values = null, string[] tags = null)
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
        // note: this call must come before calling detach or .parent will return the root identifier
        _detachInfo = DetachInfo(parent, index, IsDetached.yes);
        tclEvalFmt("%s detach %s", _name, _treeID);
    }

    /**
        Reattach this tree back to its original position.
        If the tree was not detached, the function returns early.

        If the parent no longer exists, an exception is thrown.
        If the index is out of bounds, the tree will be attached
        to the last position.
    */
    void reattach()
    {
        // no need to attach
        if (_detachInfo.isDetached == IsDetached.no)
            return;

        enforce(!_detachInfo.parent._isDestroyed,
            "Cannot reattach tree because its parent was destroyed.");

        // todo: provide a better implementation
        auto treeCount = tclEvalFmt("%s children %s", _name, _detachInfo.parent._treeID).splitter(" ").walkLength;

        // readjust index if it's out of bounds
        if (_detachInfo.index >= treeCount)
            _detachInfo.index = treeCount - 1;

        _detachInfo.parent.attach(this, _detachInfo.index);
        _detachInfo.isDetached = IsDetached.no;
    }

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

    /** Return the parent of this tree, or null if this is the root tree. */
    @property Tree parent()
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

    /** Return the previous sibling tree, or null if this is the first child of its parent. */
    Tree prevTree()
    {
        string prevID = tclEvalFmt("%s prev %s", _name, _treeID);

        if (prevID.empty)
            return null;

        enforce(prevID in _rootTree._treeIDMap,
            format("Cannot return previous tree because it was destroyed."));

        return _rootTree._treeIDMap[prevID];
    }

    /** Return the next sibling tree, or null if this is the last child of its parent. */
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

    /** Select the trees provided. */
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
        use $(D targetTree.parent is containerTree).
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
    Tree getFocus()
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

    /** Get the options for the row this tree belongs to. */
    @property RowOptions rowOptions()
    {
        RowOptions options;

        options.text = tclEvalFmt("%s item %s -text", _name, _treeID);

        string imagePath = tclEvalFmt("%s item %s -image", _name, _treeID);
        options.image = cast(Image)Widget.lookupWidgetPath(imagePath);

        options.values = tclEvalFmt("%s item %s -values", _name, _treeID).split;

        string isOpenStr = tclEvalFmt("%s item %s -open", _name, _treeID);
        options.isOpened = (isOpenStr == "1" || isOpenStr == "true") ? IsOpened.yes : IsOpened.no;

        options.tags = tclEvalFmt("%s item %s -tags", _name, _treeID).split;

        return options;
    }

    /** Set the options for the row this tree belongs to. */
    @property void rowOptions(RowOptions options)
    {
        tclEvalFmt("%s item %s -text %s", _name, _treeID, options.text._tclEscape);
        tclEvalFmt("%s item %s -values [list %s]", _name, _treeID, options.values.join(" "));
        tclEvalFmt("%s item %s -open %s", _name, _treeID, cast(int)options.isOpened);
        tclEvalFmt("%s item %s -tags [list %s]", _name, _treeID, options.tags.join(" "));
        tclEvalFmt("%s item %s -image %s", _name, _treeID, options.image ? options.image._name : "{}");
    }

    /** Set the value for the column at the specified index. */
    void setColumn(int index, string value)
    {
        tclEvalFmt("%s set %s %s %s", _name, _treeID, index, value._tclEscape);
    }

    /**
        Return the column options of the column at the index.

        Note: The index does not include the tree column,
        for that use $(D treeColumnOptions) instead.
    */
    ColumnOptions columnOptions(int index)
    {
        ColumnOptions options;

        options._name = tclEvalFmt("%s column %s -id", _name, index);
        options._anchor = tclEvalFmt("%s column %s -anchor", _name, index).toAnchor();
        options._minWidth = tclEvalFmt("%s column %s -minwidth", _name, index).to!int;
        options._doStretch = cast(DoStretch)tclEvalFmt("%s column %s -stretch", _name, index).to!int;
        options._width = tclEvalFmt("%s column %s -width", _name, index).to!int;

        return options;
    }

    /**
        Set the column options for the column at the index.

        Note: The index does not include the tree column,
        for that use $(D treeColumnOptions) instead.
    */
    void setColumnOptions(int index, ColumnOptions options)
    {
        tclEvalFmt("%s column %s -anchor %s", _name, index, options._anchor.toString());
        tclEvalFmt("%s column %s -minwidth %s", _name, index, options._minWidth);
        tclEvalFmt("%s column %s -stretch %s", _name, index, cast(int)options._doStretch);
        tclEvalFmt("%s column %s -width %s", _name, index, options._width);
    }

    /** Get the tree column options. */
    @property ColumnOptions treeColumnOptions()
    {
        ColumnOptions options;

        options._name = tclEvalFmt("%s column #0 -id", _name);
        options._anchor = tclEvalFmt("%s column #0 -anchor", _name).toAnchor();
        options._minWidth = tclEvalFmt("%s column #0 -minwidth", _name).to!int;
        options._doStretch = cast(DoStretch)tclEvalFmt("%s column #0 -stretch", _name).to!int;
        options._width = tclEvalFmt("%s column #0 -width", _name).to!int;

        return options;
    }

    /** Set the tree column options. */
    @property void treeColumnOptions(ColumnOptions options)
    {
        tclEvalFmt("%s column #0 -anchor %s", _name, options._anchor.toString());
        tclEvalFmt("%s column #0 -minwidth %s", _name, options._minWidth);
        tclEvalFmt("%s column #0 -stretch %s", _name, cast(int)options._doStretch);
        tclEvalFmt("%s column #0 -width %s", _name, options._width);
    }

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

    /**
        Return the heading options of the column at the index.

        Note: The index does not include the tree column heading,
        for that use $(D treeHeadingOptions) instead.
    */
    HeadingOptions headingOptions(int index)
    {
        HeadingOptions options;

        // todo: command
        options.text   = tclEvalFmt("%s heading %s -text", _name, index);
        options.anchor = tclEvalFmt("%s heading %s -anchor", _name, index).toAnchor();

        string imagePath = tclEvalFmt("%s heading %s -image", _name, index);
        options.image = cast(Image)Widget.lookupWidgetPath(imagePath);

        return options;
    }

    /**
        Set the heading options for the column at the index.

        Note: The index does not include the tree column,
        for that use $(D treeHeadingOptions) instead.
    */
    void setHeadingOptions(int index, HeadingOptions options)
    {
        // todo: command
        tclEvalFmt("%s heading %s -text %s", _name, index, options.text._tclEscape);
        tclEvalFmt("%s heading %s -anchor %s", _name, index, options.anchor.toString());
        tclEvalFmt("%s heading %s -image %s", _name, index, options.image ? options.image._name : "{}");
    }

    /** Get the tree column heading options. */
    @property HeadingOptions treeHeadingOptions()
    {
        HeadingOptions options;

        // todo: command
        options.text   = tclEvalFmt("%s heading #0 -text", _name);
        options.anchor = tclEvalFmt("%s heading #0 -anchor", _name).toAnchor();

        string imagePath = tclEvalFmt("%s heading #0 -image", _name);
        options.image = cast(Image)Widget.lookupWidgetPath(imagePath);

        return options;
    }

    /** Set the tree column heading options. */
    @property void treeHeadingOptions(HeadingOptions options)
    {
        // todo: command
        tclEvalFmt("%s heading #0 -text %s", _name, options.text._tclEscape);
        tclEvalFmt("%s heading #0 -anchor %s", _name, options.anchor.toString());
        tclEvalFmt("%s heading #0 -image %s", _name, options.image ? options.image._name : "{}");
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
        Note: parent and index are only kept up to date in the last detach
        call. Only use these in the reattach call, when isDetached
        equals IsDetached.yes.
    */
    static struct DetachInfo
    {
        Tree parent;
        int index;
        IsDetached isDetached;
    }

    /**
        When a tree is detached, it loses its parent and index information.
        We have to store this before detaching so we can re-attach back
        to its original place when reattach is called.
    */
    DetachInfo _detachInfo;
}
