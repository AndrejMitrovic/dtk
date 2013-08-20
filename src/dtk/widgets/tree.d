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
        _treeIDMap["{}"] = this;

        _columnIndexes = cast(int[])iota(0, columns.length).array;
    }

    /**
        name is the name of the root Tk tree widget.
        treeIdent is used in add and insert calls.
    */
    private this(Tree rootTree, string name, string treeIdent)
    {
        super(CreateFakeWidget.init);
        _treeIdent = treeIdent;
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
        return new Tree(_rootTree, _name, this.evalFmt("%s insert %s end -text %s", _name, _treeIdent, text._enquote));
    }

    /**
        Add an item to this tree at a specific index.

        Returns the tree of the item to be added.
        This tree is needed if you want to add a child item
        to this tree.
    */
    Tree insert(int index, string text, Image image = null, bool isOpened = false, string[] values = null, string[] tags = null)
    {
        return new Tree(_rootTree, _name, this.evalFmt("%s insert %s %s -text %s", _name, _treeIdent, index, text._enquote));
    }

    /** Return the children of this tree. */
    @property Tree[] children()
    {
        Appender!(Tree[]) result;

        string treePaths = this.evalFmt("%s children %s", _name, _treeIdent);

        foreach (treePath; treePaths.splitter(" "))
        {
            enforce(treePath in _rootTree._treeIDMap, format("%s not in %s", treePath, _rootTree._treeIDMap));

            auto tree = _rootTree._treeIDMap[treePath];
            if (tree !is null)
                result ~= tree;
        }

        return result.data;
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

    /** Return the tree column options. */
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

    /**
        Set the tree column options.

        Note: The index does not include the tree column,
        for that use $(D treeColumnOptions) instead.
    */
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

    ///
    override string toString()
    {
        string text = this.evalFmt("%s item %s -text", _name, _treeIdent);
        return format("%s(%s)", typeof(this).stringof, text);
    }

private:
    string _treeIdent = "{}";
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
}
