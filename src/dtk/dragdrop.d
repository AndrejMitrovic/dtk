/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.dragdrop;

import core.atomic;
import core.memory;
import core.stdc.string;

import std.exception;
import std.stdio;
import std.string;
import std.typecons;

import dtk.dispatch;
import dtk.event;
import dtk.geometry;
import dtk.interpreter;
import dtk.types;

import dtk.widgets.widget;
import dtk.widgets.window;

import win32.commctrl;
import win32.objidl;
import win32.ole2;
import win32.uuid;
import win32.windef;
import win32.winuser;
import win32.wingdi;
import win32.wingdi;

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
            stderr.writefln("+ Registering   D&D: %X", _hwnd);

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
            stderr.writefln("- Unregistering D&D: %X", _hwnd);

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

class DropTarget : ComObject, IDropTarget
{
    this(Widget widget)
    {
        _widget = widget;
    }

    override HRESULT QueryInterface(IID* riid, void** ppv)
    {
        if (*riid == IID_IDropTarget)
        {
            *ppv = cast(void*)this;
            AddRef();
            return S_OK;
        }
        else
        if (*riid == IID_IUnknown)
        {
            *ppv = cast(void*)this;
            AddRef();
            return S_OK;
        }
        else
        {
            *ppv = null;
            return E_NOINTERFACE;
        }

        return super.QueryInterface(riid, ppv);
    }

    HRESULT DragEnter(IDataObject pDataObject, DWORD grfKeyState, POINTL pt, DWORD *pdwEffect)
    {
        _lastPt = pt;
        _pDataObject = pDataObject;
        return dispatchEvent(DragDropAction.enter, grfKeyState, pt, pdwEffect);
    }

    HRESULT DragOver(DWORD grfKeyState, POINTL pt, DWORD *pdwEffect)
    {
        // Note: DragOver is repeatedly called even if the mouse is not moved,
        // it's likely called using a timer. We only dispatch the event if
        // the mouse has moved away from its previous position, but we still
        // have to mark whether the drag & drop is accepted on each call.

        if (pt == _lastPt)  // mouse hasn't moved, don't dispatch.
        {
            if (_lastDropAccepted)
                *pdwEffect = DROPEFFECT.DROPEFFECT_COPY;
            else
                *pdwEffect = DROPEFFECT.DROPEFFECT_NONE;

            return S_OK;
        }

        _lastPt = pt;
        return dispatchEvent(DragDropAction.move, grfKeyState, pt, pdwEffect);
    }

    HRESULT DragLeave()
    {
        return dispatchLeaveEvent();
    }

    HRESULT Drop(IDataObject pDataObject, DWORD grfKeyState, POINTL pt, DWORD *pdwEffect)
    {
        return dispatchEvent(DragDropAction.drop, grfKeyState, pt, pdwEffect);
    }

private:

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

    private HRESULT dispatchEvent(DragDropAction action, DWORD grfKeyState, POINTL pt, DWORD *pdwEffect)
    {
        auto position = getRelativePoint(_widget, pt);
        auto keyMod = getKeyMod(grfKeyState);
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!DragDropEvent(_widget, action, position, keyMod, timeMsec);

        // todo: Once SendEvent/PostEvent are implemented we should call those functions.
        Dispatch._dispatchInternalEvent(_widget, event);

        if (event.dropAccepted)
            *pdwEffect = DROPEFFECT.DROPEFFECT_COPY;
        else
            *pdwEffect = DROPEFFECT.DROPEFFECT_NONE;

        _lastDropAccepted = event.dropAccepted;

        return S_OK;
    }

    private HRESULT dispatchLeaveEvent()
    {
        TimeMsec timeMsec = getTclTime();

        auto event = scoped!DragDropEvent(_widget, DragDropAction.leave, Point.init, KeyMod.init, timeMsec);
        Dispatch._dispatchInternalEvent(_widget, event);

        return S_OK;
    }

private:

    POINTL _lastPt;
    bool _lastDropAccepted;

    Widget _widget;
    IDataObject _pDataObject;
}
