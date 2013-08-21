/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.tree;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.range;
import std.string;

import dtk.geometry;
import dtk.utils;
import dtk.options;

import dtk.widgets.widget;

// todo: move to Image module and implement
class Image
{
}

///
struct ColumnOptions
{
    /**
        Note: Required due to allowed writing to inaccessible
        fields via field initialization:
        http://d.puremagic.com/issues/show_bug.cgi?id=10861
    */
    this(Anchor anchor, int minWidth, bool doStretch, int width)
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
    string toString()
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
    bool _doStretch;
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
        this.evalFmt("%s configure -columns %s", _name, columns.join(" ")._enquote);

        // set the tree column label
        this.evalFmt(`%s heading #0 -text %s`, _name, label._enquote);

        // set the column names
        foreach (idx, col; columns)
            this.evalFmt(`%s heading %s -text %s`, _name, idx, col._enquote);

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
    Tree add(string text, Image image = null, bool isOpened = false, string[] values = null, string[] tags = null)
    {
        return new Tree(_rootTree, _name, this.evalFmt("%s insert %s end -text %s", _name, _treeID, text._enquote));
    }

    /**
        Add an item to this tree at a specific index.

        Returns the tree of the item to be added.
        This tree is needed if you want to add a child item
        to this tree.
    */
    Tree insert(int index, string text, Image image = null, bool isOpened = false, string[] values = null, string[] tags = null)
    {
        return new Tree(_rootTree, _name, this.evalFmt("%s insert %s %s -text %s", _name, _treeID, index, text._enquote));
    }

    /** Return the index of this tree. */
    int index()
    {
        return this.evalFmt("%s index %s", _name, _treeID).to!int;
    }

    /** Attach a tree to this tree at the last position. */
    void attach(Tree tree)
    {
        this.evalFmt("%s move %s %s end", _name, tree._treeID, _treeID);
    }

    /** Attach a tree to this tree at a specific position. */
    void attach(Tree tree, int index)
    {
        this.evalFmt("%s move %s %s %s", _name, tree._treeID, _treeID, index);
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

        this.evalFmt("%s detach %s", _name, _treeID);
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
        auto treeCount = this.evalFmt("%s children %s", _name, _detachInfo.parent._treeID).splitter(" ").walkLength;

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

        this.evalFmt("%s delete %s", _name, tree._treeID);
    }

    /** Return the parent of this tree, or null if this is the root tree. */
    @property Tree parent()
    {
        if (this.isRootTree)
            return null;

        string parentID = this.evalFmt("%s parent %s", _name, _treeID);

        if (parentID.empty)  // nested right in the root tree
            return _rootTree;

        enforce(parentID in _rootTree._treeIDMap,
            format("Can't find: %s", parentID));

        auto parent = _rootTree._treeIDMap[parentID];

        enforce(!parent._isDestroyed,
            "Cannot return parent tree because it was destroyed.");

        return parent;
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
        return this.evalFmt("%s exists %s", _name, tree._treeID) == "1";
    }

    /** Return the children of this tree. */
    @property Tree[] children()
    {
        Appender!(Tree[]) result;

        string treePaths = this.evalFmt("%s children %s", _name, _treeID);

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
        string treePath = this.evalFmt("%s focus", _name);

        if (treePath.empty)
            return null;

        enforce(treePath in _rootTree._treeIDMap,
            format("%s not in %s", treePath, _rootTree._treeIDMap));

        return _rootTree._treeIDMap[treePath];
    }

    /** Set this tree to be the focused tree. */
    void setFocus()
    {
        this.evalFmt("%s focus %s", _name, _treeID);
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

    /**
        Return the column options of the column at the index.

        Note: The index does not include the tree column,
        for that use $(D treeColumnOptions) instead.
    */
    ColumnOptions columnOptions(int index)
    {
        ColumnOptions options;

        options._name = this.evalFmt("%s column %s -id", _name, index);
        options._anchor = this.evalFmt("%s column %s -anchor", _name, index).toAnchor();
        options._minWidth = this.evalFmt("%s column %s -minwidth", _name, index).to!int;
        options._doStretch = this.evalFmt("%s column %s -stretch", _name, index).to!int == 1;
        options._width = this.evalFmt("%s column %s -width", _name, index).to!int;

        return options;
    }

    /**
        Set the column options for the column at the index.

        Note: The index does not include the tree column,
        for that use $(D treeColumnOptions) instead.
    */
    void setColumnOptions(int index, ColumnOptions options)
    {
        this.evalFmt("%s column %s -anchor %s", _name, index, options._anchor.toString());
        this.evalFmt("%s column %s -minwidth %s", _name, index, options._minWidth);
        this.evalFmt("%s column %s -stretch %s", _name, index, options._doStretch ? 1 : 0);
        this.evalFmt("%s column %s -width %s", _name, index, options._width);
    }

    /** Get the tree column options. */
    @property ColumnOptions treeColumnOptions()
    {
        ColumnOptions options;

        options._name = this.evalFmt("%s column #0 -id", _name);
        options._anchor = this.evalFmt("%s column #0 -anchor", _name).toAnchor();
        options._minWidth = this.evalFmt("%s column #0 -minwidth", _name).to!int;
        options._doStretch = this.evalFmt("%s column #0 -stretch", _name).to!int == 1;
        options._width = this.evalFmt("%s column #0 -width", _name).to!int;

        return options;
    }

    /** Set the tree column options. */
    @property void treeColumnOptions(ColumnOptions options)
    {
        this.evalFmt("%s column #0 -anchor %s", _name, options._anchor.toString());
        this.evalFmt("%s column #0 -minwidth %s", _name, options._minWidth);
        this.evalFmt("%s column #0 -stretch %s", _name, options._doStretch ? 1 : 0);
        this.evalFmt("%s column #0 -width %s", _name, options._width);
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

        // todo: image and command
        options.text   = this.evalFmt("%s heading %s -text", _name, index);
        options.anchor = this.evalFmt("%s heading %s -anchor", _name, index).toAnchor();

        return options;
    }

    /**
        Set the heading options for the column at the index.

        Note: The index does not include the tree column,
        for that use $(D treeHeadingOptions) instead.
    */
    void setHeadingOptions(int index, HeadingOptions options)
    {
        // todo: image and command
        this.evalFmt("%s heading %s -text %s", _name, index, options.text._enquote);
        this.evalFmt("%s heading %s -anchor %s", _name, index, options.anchor.toString());
    }

    /** Get the tree column heading options. */
    @property HeadingOptions treeHeadingOptions()
    {
        HeadingOptions options;

        // todo: image and command
        options.text   = this.evalFmt("%s heading #0 -text", _name);
        options.anchor = this.evalFmt("%s heading #0 -anchor", _name).toAnchor();

        return options;
    }

    //~ /** Set the tree column heading options. */
    @property void treeHeadingOptions(HeadingOptions options)
    {
        // todo: image and command
        this.evalFmt("%s heading #0 -text %s", _name, options.text._enquote);
        this.evalFmt("%s heading #0 -anchor %s", _name, options.anchor.toString());
    }

    ///
    override string toString()
    {
        string text = this.evalFmt("%s item %s -text", _name, _treeID);
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
