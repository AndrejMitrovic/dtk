/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.layout;

import dtk.geometry;
import dtk.imports;
import dtk.interpreter;
import dtk.utils;

import dtk.widgets.widget;

void pack(Widget widget)
{
    tclEvalFmt("pack %s", widget._name);
}

/**
    Layout or configure grid options for this widget.
*/
Grid grid(Widget widget)
{
    return Grid(widget);
}

struct GridCell
{
    int row;
    int col;
}

struct GridSize
{
    int rows;
    int cols;
}

struct Grid
{
    this(Widget widget)
    {
        _widget = widget;
    }

    @property Anchor anchor()
    {
        return tclEvalFmt("grid anchor %s", _widget._name).toAnchor();
    }

    @property void anchor(Anchor newAnchor)
    {
        tclEvalFmt("grid anchor %s %s", _widget._name, newAnchor.toString());
    }

    @property bool propagate()
    {
        return cast(bool)(tclEvalFmt("grid propagate %s", _widget._name).to!int);
    }

    @property void propagate(bool doPropagate)
    {
        tclEvalFmt("grid propagate %s %s", _widget._name, cast(int)doPropagate);
    }

    @property GridSize size()
    {
        auto res = tclEvalFmt("grid size %s", _widget._name).splitter(" ");

        auto cols = to!int(res.front);
        res.popFront();

        auto rows = to!int(res.front);
        return GridSize(rows, cols);
    }

    GridCell location(Point point)
    {
        auto res = tclEvalFmt("grid location %s %s %s", _widget._name, point.x, point.y).splitter(" ");

        auto col = to!int(res.front);
        res.popFront();

        auto row = to!int(res.front);
        return GridCell(row, col);
    }

    /** Get the bounding box of the entire grid. */
    Rect boundBox()
    {
        return tclEvalFmt("grid bbox %s", _widget._name)._toBoundBox();
    }

    /** Get the bounding box of a grid cell. */
    Rect boundBox(int row, int col)
    {
        return tclEvalFmt("grid bbox %s %s %s", _widget._name, row, col)._toBoundBox();
    }

    /** Get the bounding box of a grid cell range. */
    Rect boundBox(int row1, int col1, int row2, int col2)
    {
        return tclEvalFmt("grid bbox %s %s %s %s %s", _widget._name, col1, row1, col2, row2)._toBoundBox();
    }

    ColRowOptions rowOptions(int row)
    {
        return typeof(return)(_widget, row, "rowconfigure");
    }

    ColRowOptions colOptions(int col)
    {
        return typeof(return)(_widget, col, "columnconfigure");
    }

    Widget[] slaves()
    {
        return walkSlaves().array;
    }

    auto walkSlaves()
    {
        string paths = tclEvalFmt("grid slaves %s", _widget._name);
        return map!(a => Widget.lookupWidgetPath(a))(paths.splitter);
    }

    Widget[] rowSlaves(int row)
    {
        return walkRowSlaves(row).array;
    }

    auto walkRowSlaves(int row)
    {
        string paths = tclEvalFmt("grid slaves %s -row %s", _widget._name, row);
        return map!(a => Widget.lookupWidgetPath(a))(paths.splitter);
    }

    Widget[] colSlaves(int col)
    {
        return walkColSlaves(col).array;
    }

    auto walkColSlaves(int col)
    {
        string paths = tclEvalFmt("grid slaves %s -column %s", _widget._name, col);
        return map!(a => Widget.lookupWidgetPath(a))(paths.splitter);
    }

    /** Lay out this widget into a grid row. */
    @property void row(int newRow)
    {
        tclEvalFmt("grid configure %s -row %s", _widget._name, newRow);
    }

    @property void col(int newCol)
    {
        tclEvalFmt("grid configure %s -column %s", _widget._name, newCol);
    }

    @property void rowSpan(int newRowSpan)
    {
        tclEvalFmt("grid configure %s -rowspan %s", _widget._name, newRowSpan);
    }

    @property void colSpan(int newColSpan)
    {
        tclEvalFmt("grid configure %s -columnspan %s", _widget._name, newColSpan);
    }

    @property void interPadX(int newInterPadX)
    {
        tclEvalFmt("grid configure %s -ipadx %s", _widget._name, newInterPadX);
    }

    @property void interPadY(int newInterPadY)
    {
        tclEvalFmt("grid configure %s -ipady %s", _widget._name, newInterPadY);
    }

    @property void padX(int newPadX)
    {
        tclEvalFmt("grid configure %s -padx %s", _widget._name, newPadX);
    }

    @property void padY(int newPadY)
    {
        tclEvalFmt("grid configure %s -pady %s", _widget._name, newPadY);
    }

    @property void sticky(Sticky newSticky)
    {
        tclEvalFmt("grid configure %s -sticky %s", _widget._name, newSticky);
    }

    void forget()
    {
        tclEvalFmt("grid forget %s", _widget._name);
    }

    void remove()
    {
        tclEvalFmt("grid remove %s", _widget._name);
    }

    void reset()
    {
        tclEvalFmt("grid %s", _widget._name);
    }

    /*
        @bug: Issue 11119: Alias declaration cannot see
        forward-referenced symbol in mixed-in template,
        has to be mixed-in before usage.
    */
    private mixin _mixinChainerFunc;

    /**
        These are convenience functions that are otherwise equivalent to the
        ones listed above, but which can be used in function chaining.
    */
    alias setRow = _chainerFunc!row;

    /// ditto
    alias setCol = _chainerFunc!col;

    /// convenience alias.
    alias setColumn = setCol;

    /// ditto
    alias setRowSpan = _chainerFunc!rowSpan;

    /// ditto
    alias setColSpan = _chainerFunc!colSpan;

    /// convenience alias.
    alias setColumnSpan = setColSpan;

    /// ditto
    alias setInterPadX = _chainerFunc!interPadX;

    /// ditto
    alias setInterPadY = _chainerFunc!interPadY;

    /// ditto
    alias setPadX = _chainerFunc!padX;

    /// ditto
    alias setPadY = _chainerFunc!padY;

    /// ditto
    alias setSticky = _chainerFunc!sticky;

private:
    Widget _widget;
}

/** Options struct used for both columns and rows. */
struct ColRowOptions
{
    @property int minSize()
    {
        return tclEvalFmt("grid %s %s %s -minsize", _tkType, _widget._name, _target).to!int;
    }

    @property void minSize(int newMinSize)
    {
        tclEvalFmt("grid %s %s %s -minsize %s", _tkType, _widget._name, _target, newMinSize);
    }

    @property int weight()
    {
        return tclEvalFmt("grid %s %s %s -weight", _tkType, _widget._name, _target).to!int;
    }

    @property void weight(int newWeight)
    {
        tclEvalFmt("grid %s %s %s -weight %s", _tkType, _widget._name, _target, newWeight);
    }

    @property string uniform()
    {
        return tclEvalFmt("grid %s %s %s -uniform", _tkType, _widget._name, _target);
    }

    @property void uniform(string newUniform)
    {
        tclEvalFmt("grid %s %s %s -uniform %s", _tkType, _widget._name, _target, newUniform._tclEscape);
    }

    @property int pad()
    {
        return tclEvalFmt("grid %s %s %s -pad", _tkType, _widget._name, _target).to!int;
    }

    @property void pad(int newPad)
    {
        tclEvalFmt("grid %s %s %s -pad %s", _tkType, _widget._name, _target, newPad);
    }

    /*
        @bug: Issue 11119: Alias declaration cannot see
        forward-referenced symbol in mixed-in template,
        has to be mixed-in before usage.
        private mixin _mixinChainerFunc;

        @bug: Issue 11120: Cannot use a single _chainerFunc template
        due to the wrong property being called when using ParemeterTypeTuple
        internally.
    */

    // @bug: Issue 11120 workaround: Have to use explicit Params type
    template _chainerFunc(alias symbol, Params)
    {
        // alias Params = ParameterTypeTuple!symbol;
        auto ref _chainerFunc(Params args)
        {
            symbol = args;
            return this;
        }
    }

    /**
        These are convenience functions that are otherwise equivalent to the
        ones listed above, but which can be used in function chaining.
    */
    alias setMinSize = _chainerFunc!(minSize, int);

    /// ditto
    alias setWeight = _chainerFunc!(weight, int);

    /// ditto
    alias setUniform = _chainerFunc!(uniform, string);

    /// ditto
    alias setPad = _chainerFunc!(pad, int);

private:
    Widget _widget;
    int _target;
    string _tkType;
}

private Rect _toBoundBox(string input)
{
    auto res = map!(to!int)(input.splitter(" "));

    Rect rect;

    foreach (ref val; rect.tupleof)
    {
        val = res.front;
        res.popFront();
    }

    return rect;
}

// Note: Can't be a naked template due to 'symbol' requiring the 'this' object
private mixin template _mixinChainerFunc()
{
    template _chainerFunc(alias symbol)
    {
        alias Params = ParameterTypeTuple!symbol;

        auto ref _chainerFunc(Params args)
        {
            symbol = args;
            return this;
        }
    }
}
