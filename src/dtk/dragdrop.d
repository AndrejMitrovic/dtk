/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.dragdrop;

import std.variant;

import dtk.platform;

import dtk.widgets.widget;

/** Specifies whether data can be moved. */
enum CanMoveData
{
    no,   ///
    yes,  ///
}

/** Specifies whether data can be copied. */
enum CanCopyData
{
    no,   ///
    yes,  ///
}

/**
    The drag data can store any type which a Variant can accept.
*/
struct DragData
{
    /**
        Construct the drag data with $(D data).
        $(D canMoveData) and $(D canCopyData) mark
        whether the data can be moved or copied.
    */
    this(DataType)(DataType data, CanMoveData canMoveData, CanCopyData canCopyData)
    {
        _data = data;
        _canMove = cast(bool)canMoveData;
        _canCopy = cast(bool)canCopyData;
    }

    /** Check whether this drag data can be moved. */
    @property bool canMove() { return _canMove; }

    /** Check whether this drag data can be copied. */
    @property bool canCopy() { return _canCopy; }

package:
    Variant _data;

private:
    bool _canMove;
    bool _canCopy;
}

/** Start a drag & drop operation. */
void startDragDrop(Widget widget, DragData dragData)
{
    nativeStartDragDrop(widget, dragData);
}
