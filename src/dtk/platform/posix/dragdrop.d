/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.platform.posix.dragdrop;

version (Posix):

import dtk.app;
import dtk.dispatch;
import dtk.dragdrop;
import dtk.event;
import dtk.geometry;
import dtk.interpreter;
import dtk.types;
import dtk.utils;

import dtk.widgets.widget;

import dtk.platform.posix.defs;

static void _initDragDrop()
{

}

void registerDragDrop(HWND hwnd, DropTarget dropTarget)
{

}

void unregisterDragDrop(HWND hwnd)
{

}

/**
    The native drag data store the initial drag data
    and additionally the processID. This is required for
    safety checks when transfering data from one process
    to another.

    If the process ID of the source and target do not
    match then only data without indirections (PODs) can
    be transfered (POD == plain old datatype).
*/
private struct NativeDragData
{
    void* _processID;
    DragData _dragData;
    alias _dragData this;
}

void nativeStartDragDrop(Widget widget, DragData inDragData)
{

}

/**
    This is a DTK data object.

    It retrieves the data stored in a NativeDragData struct.

    Note:
    Dragging between DTK widgets is easy, however dragging outside
    to e.g. an explorer window or another application requires
    that we implement all COM methods properly.

    We should support e.g. dragging a label's text to an edit
    control of another application. Or even support dragging
    a widget to an Explorer window, which would somehow
    serialize the widget for later re-use. This also implies
    an explorer window could drag a file into a DTK window
    and have it unserialize the data.
*/

/**
    Retrieved by a DTK widget.
*/
struct DropData
{
    package bool hasData(T)()
    {
        static if (is(T == string))
            return hasAsciiString() || hasWideString() || hasDtkDragData!T();
        else
            return hasDtkDragData!T();
    }

    package T getData(T)()
    {
        static if (is(T == string))
        {
            if (hasWideString())
                return getWideString();
            else
            if (hasAsciiString())
                return getAsciiString();
            else
            if (hasDtkDragData!T())
                return getDtkDragData!T();
            else
                assert(0, format("Drop data does not contain any data of type '%s'.", T.stringof));
        }
        else
        {
            return getDtkDragData!T();
        }
    }

    private bool hasAsciiString()
    {
        return false;
    }

    private bool hasWideString()
    {
        return false;
    }

    private bool hasDtkDragData(T)()
    {
        return false;
    }

private:

    private string getAsciiString()
    {
        return "";
    }

    private string getWideString()
    {
        return "";
    }

    // get the type that a dtk drag data supports
    private T getDtkDragData(T)()
    {
        return T.init;
    }
}

class DropTarget
{
}

/** Get a new drop target. */
DropTarget createDropTarget(Widget widget)
{
    return typeof(return).init;
}
