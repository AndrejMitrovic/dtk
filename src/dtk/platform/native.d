/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.platform.native;

version (Windows)
{
    import dtk.platform.win32.com;
    import dtk.platform.win32.defs;
    import dtk.platform.win32.dragdrop;

    alias WinHandle = HWND;
    alias startDragEvent = dtk.platform.win32.dragdrop.startDragEvent;
    alias CanMoveData = dtk.platform.win32.dragdrop.CanMoveData;
    alias CanCopyData = dtk.platform.win32.dragdrop.CanCopyData;
    alias DragData = dtk.platform.win32.dragdrop.DragData;
    alias DropData = dtk.platform.win32.dragdrop.DropData;
    alias DropTarget = dtk.platform.win32.dragdrop.DropTarget;
    alias registerDragDrop = dtk.platform.win32.dragdrop.registerDragDrop;
    alias unregisterDragDrop = dtk.platform.win32.dragdrop.unregisterDragDrop;
    alias createDropTarget = dtk.platform.win32.dragdrop.createDropTarget;
}
else
static assert(0);
