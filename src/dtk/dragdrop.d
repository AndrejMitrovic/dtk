/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.dragdrop;

import std.exception;
import std.stdio;
import std.traits;
import std.typecons;

import dtk.app;
import dtk.dispatch;
import dtk.event;
import dtk.geometry;
import dtk.interpreter;
import dtk.types;
import dtk.utils;

import dtk.platform.win32.defs;
import dtk.platform.win32.com;

import dtk.widgets.widget;
import dtk.widgets.window;

//~ import win32.objidl;
//~ import win32.ole2;
//~ import win32.winbase;
//~ import win32.windef;
//~ import win32.winuser;
//~ import win32.wtypes;

auto dragDrop(Widget widget)
{
    return DragDrop(widget);
}

struct DragDrop
{
    @disable this();

    this(Widget widget)
    {
        _widget = widget;
        _hwnd = _widget.getHWND();
    }

    /** Check whether this widget has been registered for the drag & drop operations. */
    bool isRegistered()
    {
        return _widget._dropTarget !is null;
    }

    /** Register the widget to accept drag & drop operations. */
    void register()
    {
        if (_widget._dropTarget !is null)
            return;

        version (DTK_LOG_COM)
            stderr.writefln("+ Registering d&d  : %X", _hwnd);

        _widget._dropTarget = newCom!DropTarget(_widget);
        scope (failure)
            _widget._dropTarget = null;

        _register(_hwnd, _widget._dropTarget);

        // widget must be unregistered before Tk's HWND becomes invalid.
        _widget._onAPIDestroyEvent ~= &unregister;
    }

    /** Unregister the widget. */
    void unregister()
    {
        if (_widget._dropTarget is null)
            return;

        version (DTK_LOG_COM)
            stderr.writefln("- Unregistering d&d: %X", _hwnd);

        _unregister(_hwnd);
        _widget._dropTarget = null;
    }

    private static void _register(HWND hwnd, DropTarget dropTarget)
    {
        auto res = RegisterDragDrop(hwnd, dropTarget);
        enforce(res == S_OK || res == DRAGDROP_E_ALREADYREGISTERED,
            format("Could not register handle '%s'. Error code: %s", hwnd, res));
    }

    private static void _unregister(HWND hwnd)
    {
        auto res = RevokeDragDrop(hwnd);
        enforce(res == S_OK || res == DRAGDROP_E_NOTREGISTERED,
            format("Could not unregister handle '%s'. Error code: %s", hwnd, res));
    }

private:
    Widget _widget;
    HWND _hwnd;
}

struct DropData
{
    package bool hasData(T)() if (is(T == string))
    {
        static FORMATETC fmtetc = { CF_TEXT, null, DVASPECT.DVASPECT_CONTENT, -1, TYMED.TYMED_HGLOBAL };
        return _dataObject.QueryGetData(&fmtetc) == S_OK;
    }

    package T getData(T)() if (is(T == string))
    {
        // construct a FORMATETC object
        FORMATETC fmtetc = { CF_TEXT, null, DVASPECT.DVASPECT_CONTENT, -1, TYMED.TYMED_HGLOBAL };
        STGMEDIUM stgmed;
        readData!T(&fmtetc, &stgmed);

        // we asked for the data as a HGLOBAL, so access it appropriately
        auto data = cast(char*)GlobalLock(stgmed.hGlobal);
        string result = to!string(data);
        GlobalUnlock(stgmed.hGlobal);
        ReleaseStgMedium(&stgmed);
        return result;
    }

private:
    private void readData(T)(FORMATETC* fmtetc, STGMEDIUM* stgmed)
    {
        enforce(_dataObject.QueryGetData(fmtetc) == S_OK,
                format("Drop data does not contain any data of type '%s'", T.stringof));

        enforce(_dataObject.GetData(fmtetc, stgmed) == S_OK,
                format("Could not read drop data of type '%s'", T.stringof));
    }

private:
    IDataObject _dataObject;
}

class DropTarget : ComObject, IDropTarget
{
    this(Widget widget)
    {
        _widget = widget;
    }

    override HRESULT QueryInterface(const(IID)* riid, void** ppv)
    {
        if (*riid == IID_IDropTarget)
        {
            *ppv = cast(void*)cast(IUnknown)this;
            AddRef();
            return S_OK;
        }

        return super.QueryInterface(riid, ppv);
    }

    mixin ComThrowWrapper!(DragEnterImpl, "DragEnter");
    mixin ComThrowWrapper!(DragOverImpl, "DragOver");
    mixin ComThrowWrapper!(DropImpl, "Drop");
    mixin ComThrowWrapper!(DragLeaveImpl, "DragLeave");

private:

    private HRESULT DragEnterImpl(IDataObject dataObject, DWORD grfKeyState, POINTL pt, DWORD *pdwEffect)
    {
        _dropData._dataObject = dataObject;
        auto result = dispatchEvent(DropAction.enter, grfKeyState, pt, pdwEffect);

        /**
            Note: On entry pdwEffect will hold a bitmask of all allowed effects,
            but on exit it must be set to just one value. On DragEnter the user-provided
            event handler usually doesn't do any copy or read yet, so this will
            leave pdwEffect in the original state (bitmask of all allowed effects).
            We have to explicitly pick one of the possible result values here.
        */
        auto effect = *pdwEffect;
        if (effect & DROPEFFECT.DROPEFFECT_NONE)
        { }  // the event handler rejected the drop operation
        else
        {
            foreach (memb; EnumMembers!DROPEFFECT)
            static if (memb != DROPEFFECT.DROPEFFECT_NONE)
            {
                if (effect & memb)
                {
                    *pdwEffect = memb;
                    return result;
                }
            }
        }

        return result;
    }

    private HRESULT DragOverImpl(DWORD grfKeyState, POINTL pt, DWORD *pdwEffect)
    {
        return dispatchEvent(DropAction.move, grfKeyState, pt, pdwEffect);
    }

    private HRESULT DropImpl(IDataObject dataObject, DWORD grfKeyState, POINTL pt, DWORD *pdwEffect)
    {
        _dropData._dataObject = dataObject;
        return dispatchEvent(DropAction.drop, grfKeyState, pt, pdwEffect);
    }

    private HRESULT DragLeaveImpl()
    {
        return dispatchLeaveEvent();
    }

    private HRESULT dispatchEvent(DropAction action, DWORD grfKeyState, POINTL pt, DWORD *pdwEffect)
    {
        DropEffect dropEffect = cast(DropEffect)*pdwEffect;
        auto position = getRelativePoint(_widget, pt);
        auto keyMod = getKeyMod(grfKeyState);
        TimeMsec timeMsec = getTclTime();

        // todo: Once SendEvent/PostEvent are implemented we should use those functions.
        auto event = scoped!DragDropEvent(_widget, action, _dropData, dropEffect, position, keyMod, timeMsec);
        Dispatch._dispatchInternalEvent(_widget, event);

        if (event.acceptDrop)
            *pdwEffect = cast(DWORD)event._dropEffect;
        else
            *pdwEffect = DROPEFFECT.DROPEFFECT_NONE;

        return S_OK;
    }

    private HRESULT dispatchLeaveEvent()
    {
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!DragDropEvent(_widget, DropAction.leave, timeMsec);
        Dispatch._dispatchInternalEvent(_widget, event);

        return S_OK;
    }

    private static Point getRelativePoint(Widget targetWidget, POINTL pt)
    {
        auto point = targetWidget.absPosition();
        return Point(pt.x - point.x, pt.y - point.y);
    }

    private static KeyMod getKeyMod(DWORD grfKeyState)
    {
        KeyMod keyMod;

        if (grfKeyState & MK_CONTROL)
            keyMod |= KeyMod.control;

        if (grfKeyState & MK_ALT)
            keyMod |= KeyMod.alt;

        if (grfKeyState & MK_SHIFT)
            keyMod |= KeyMod.shift;

        if (grfKeyState & MK_LBUTTON)
            keyMod |= KeyMod.mouse_left;

        if (grfKeyState & MK_MBUTTON)
            keyMod |= KeyMod.mouse_middle;

        if (grfKeyState & MK_RBUTTON)
            keyMod |= KeyMod.mouse_right;

        return keyMod;
    }

private:
    Widget _widget;
    DropData _dropData;
    DWORD _dwEffect;
}
