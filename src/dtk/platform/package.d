/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.platform;

version (Windows)
{
    import dtk.platform.win32.com;
    import dtk.platform.win32.defs;
    import dtk.platform.win32.dragdrop;

    alias WinHandle = HWND;
    alias nativeStartDragDrop = dtk.platform.win32.dragdrop.nativeStartDragDrop;
    alias DropData = dtk.platform.win32.dragdrop.DropData;
    alias DropTarget = dtk.platform.win32.dragdrop.DropTarget;
    alias registerDragDrop = dtk.platform.win32.dragdrop.registerDragDrop;
    alias unregisterDragDrop = dtk.platform.win32.dragdrop.unregisterDragDrop;
    alias createDropTarget = dtk.platform.win32.dragdrop.createDropTarget;
}
else
version (Posix)
{
    import dtk.platform.posix.defs;
    import dtk.platform.posix.dragdrop;

    alias WinHandle = HWND;
    alias nativeStartDragDrop = dtk.platform.posix.dragdrop.nativeStartDragDrop;
    alias DropData = dtk.platform.posix.dragdrop.DropData;
    alias DropTarget = dtk.platform.posix.dragdrop.DropTarget;
    alias registerDragDrop = dtk.platform.posix.dragdrop.registerDragDrop;
    alias unregisterDragDrop = dtk.platform.posix.dragdrop.unregisterDragDrop;
    alias createDropTarget = dtk.platform.posix.dragdrop.createDropTarget;
}

else
static assert(0);
