/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.platform.win32.dragdrop;

import core.atomic;
import core.memory;

import std.exception;
import std.stdio;
import std.range;
import std.traits;
import std.typecons;
import std.variant;

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

void registerDragDrop(HWND hwnd, DropTarget dropTarget)
{
    auto res = RegisterDragDrop(hwnd, dropTarget);
    enforce(res == S_OK || res == DRAGDROP_E_ALREADYREGISTERED,
        format("Could not register handle '%s'. Error code: %s", hwnd, res));
}

void unregisterDragDrop(HWND hwnd)
{
    auto res = RevokeDragDrop(hwnd);
    enforce(res == S_OK || res == DRAGDROP_E_NOTREGISTERED,
        format("Could not unregister handle '%s'. Error code: %s", hwnd, res));
}

private static FORMATETC _dtkFormat;

static void _initDragDropFormat()
{
    auto res = RegisterClipboardFormatW("dtk_drag_drop_format");
    enforce(res != 0, format("RegisterClipboardFormat error: %s", to!string(GetLastError())));
    _dtkFormat.cfFormat = cast(CLIPFORMAT)res;
    _dtkFormat.ptd = null;
    _dtkFormat.dwAspect = DVASPECT.DVASPECT_CONTENT;
    _dtkFormat.lindex = -1;
    _dtkFormat.tymed = TYMED.TYMED_HGLOBAL;  // note: must be hglobal
}

enum CanCopyData
{
    no,
    yes,
}

enum CanMoveData
{
    no,
    yes,
}

struct DragData
{
    this(T)(T data, CanMoveData canMove, CanCopyData canCopy)
    {
        _data = data;
        _canMove = cast(bool)canMove;
        _canCopy = cast(bool)canCopy;
    }

    @property bool canMove() { return _canMove; }
    @property bool canCopy() { return _canCopy; }

private:
    Variant _data;
    bool _canMove;
    bool _canCopy;
}

class DropSource : ComObject, IDropSource
{
    extern (Windows)
    override HRESULT QueryInterface(const(IID)* riid, void** ppv)
    {
        if (*riid == IID_IDropSource)
        {
            *ppv = cast(void*)cast(IUnknown)this;
            AddRef();
            return S_OK;
        }

        return super.QueryInterface(riid, ppv);
    }

    /** Called by OLE whenever Escape/Control/Shift/Mouse buttons have changed. */
    extern (Windows)
    HRESULT QueryContinueDrag(BOOL fEscapePressed, DWORD grfKeyState)
    {
        // if the <Escape> key has been pressed since the last call, cancel the drop
        if (fEscapePressed == TRUE)
            return DRAGDROP_S_CANCEL;

        // if the <LeftMouse> button has been released, then do the drop!
        if ((grfKeyState & MK_LBUTTON) == 0)
            return DRAGDROP_S_DROP;

        // continue with the drag-drop
        return S_OK;
    }

    //	Return either S_OK or DRAGDROP_S_USEDEFAULTCURSORS to instruct OLE to use the
    //  default mouse cursor images
    extern (Windows)
    HRESULT GiveFeedback(DWORD dwEffect)
    {
        return DRAGDROP_S_USEDEFAULTCURSORS;
    }
}

void startDragEvent(Widget widget, DragData dragData)
{
    // todo: we can optimize and allocate on the stack
    IDropSource dropSource = newCom!DropSource();
    dropSource.AddRef();
    scope(exit) dropSource.Release();

    // todo: we can optimize and allocate on the stack
    IDataObject dataObject = newCom!DataObject(dragData);
    dataObject.AddRef();
    scope(exit) dataObject.Release();

    DWORD dwEffect;

    DWORD allowedEffects;
    if (dragData.canMove)
        allowedEffects |= DROPEFFECT.DROPEFFECT_MOVE;

    if (dragData.canCopy)
        allowedEffects |= DROPEFFECT.DROPEFFECT_COPY;

    DWORD dwResult = DoDragDrop(dataObject, dropSource, allowedEffects, &dwEffect);

    // todo: here we invoke the onDragEvent
    /+ if (dwResult == DRAGDROP_S_DROP)
    {
        if (dwEffect & DROPEFFECT.DROPEFFECT_MOVE)
        {
            MessageBox(null, "Moving", "Info", MB_OK);
            // todo: remove selection from edit control
        }
    }
    else if (dwResult == DRAGDROP_S_CANCEL)  // cancelled
    {
    } +/
}

private struct FormatStore
{
    FORMATETC fmtetc;
    STGMEDIUM stgmed;
}

/**
    This is explicitly a DTK data object.

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
class DataObject : ComObject, IDataObject
{
    this(DragData dragData)
    {
        _dragData = dragData;
    }

    extern (Windows)
    override HRESULT QueryInterface(const(IID)* riid, void** ppv)
    {
        if (*riid == IID_IDataObject)
        {
            *ppv = cast(void*)cast(IUnknown)this;
            AddRef();
            return S_OK;
        }

        return super.QueryInterface(riid, ppv);
    }

    /**
        Find the data of the format pFormatEtc and if found store
        it into the storage medium pMedium.
    */
    extern (Windows)
    HRESULT GetData(FORMATETC* pFormatEtc, STGMEDIUM* pMedium)
    {
        // try to match the requested FORMATETC with one of our supported formats
        auto fsRange = findFormatStore(*pFormatEtc);
        if (fsRange.empty)
            return DV_E_FORMATETC;  // pFormatEtc is invalid

        // found a match - transfer the data into the supplied pMedium
        auto formatStore = fsRange.front;

        // store the type of the format, and the release callback (null).
        pMedium.tymed = formatStore.fmtetc.tymed;
        pMedium.pUnkForRelease = null;

        // duplicate the memory
        switch (formatStore.fmtetc.tymed)
        {
            case TYMED.TYMED_HGLOBAL:
                // note: we don't need to duplicate here, since we've already allocated
                // pMedium.hGlobal = dupGlobalMem(formatStore.stgmed.hGlobal);
                pMedium.hGlobal = formatStore.stgmed.hGlobal;
                return S_OK;

            default:
                return DV_E_FORMATETC;
        }
    }

    extern (Windows)
    HRESULT GetDataHere(FORMATETC* pFormatEtc, STGMEDIUM* pMedium)
    {
        // GetDataHere is only required for IStream and IStorage mediums
        // It's an error to call GetDataHere for things like HGLOBAL and
        // other clipboard formats
        return DATA_E_FORMATETC;
    }

    // Called to see if the IDataObject supports the specified format of data
    extern (Windows)
    HRESULT QueryGetData(FORMATETC* pFormatEtc)
    {
        return findFormatStore(*pFormatEtc).empty ? DV_E_FORMATETC : S_OK;
    }

    /**
        MSDN: Provides a potentially different but logically equivalent
        FORMATETC structure. Use this method to determine whether two
        different FORMATETC structures would return the same data,
        removing the need for duplicate rendering.
    */
    extern (Windows)
    HRESULT GetCanonicalFormatEtc(FORMATETC* pFormatEtc, FORMATETC* pFormatEtcOut)
    {
        /*
            MSDN: For data objects that never provide device-specific renderings,
            the simplest implementation of this method is to copy the input
            FORMATETC to the output FORMATETC, store a NULL in the ptd member of
            the output FORMATETC and return DATA_S_SAMEFORMATETC.
        */
        *pFormatEtcOut = deepDupFormatEtc(*pFormatEtc);
        pFormatEtcOut.ptd = null;
        return DATA_S_SAMEFORMATETC;
    }

    extern (Windows)
    HRESULT SetData(FORMATETC* pFormatEtc, STGMEDIUM* pMedium, BOOL fRelease)
    {
        return E_NOTIMPL;
    }

    /**
        Create and store an object into ppEnumFormatEtc which enumerates the
        formats supported by this DataObject instance.
    */
    extern (Windows)
    HRESULT EnumFormatEtc(DWORD dwDirection, IEnumFORMATETC* ppEnumFormatEtc)
    {
        // todo: implement later, even though most apps don't seem to use this.
        return E_NOTIMPL;
    }

    extern (Windows)
    HRESULT DAdvise(FORMATETC* pFormatEtc, DWORD advf, IAdviseSink pAdvSink, DWORD* pdwConnection)
    {
        return OLE_E_ADVISENOTSUPPORTED;
    }

    extern (Windows)
    HRESULT DUnadvise(DWORD dwConnection)
    {
        return OLE_E_ADVISENOTSUPPORTED;
    }

    extern (Windows)
    HRESULT EnumDAdvise(IEnumSTATDATA* ppEnumAdvise)
    {
        return OLE_E_ADVISENOTSUPPORTED;
    }

private:
    struct Range
    {
        this(FormatStore formatStore)
        {
            _formatStore = formatStore;
            _empty = false;
        }

        @property bool empty() { return _empty; }
        @property FormatStore front() { return _formatStore; }
        void popFront() { _empty = true; }

    private:
        FormatStore _formatStore;
        bool _empty = true;
    }

    /**
        Find the format store in our list of supported formats,
        or return an empty range if not found.
    */
    private Range findFormatStore(FORMATETC fmtetc)
    {
        /* Only support content type in global memory. */
        if (fmtetc.dwAspect != DVASPECT.DVASPECT_CONTENT
            || fmtetc.tymed != TYMED.TYMED_HGLOBAL)
            return Range();

        switch (fmtetc.cfFormat)
        {
            case CF_TEXT:
                return getAsciiString();

            case CF_UNICODETEXT:
                return getWideString();

            default:
                return Range();
        }
    }

    private Range getAsciiString()
    {
        auto ptr = _dragData._data.peek!string;
        if (ptr is null)
            return Range();

        if (!(*ptr).isAsciiString)
            return Range();

        FORMATETC fmtetc = { CF_TEXT, null, DVASPECT.DVASPECT_CONTENT, -1, TYMED.TYMED_HGLOBAL };
        STGMEDIUM stgmed = { TYMED.TYMED_HGLOBAL };

        // format matches, copy text data to global memory
        stgmed.hGlobal = copyAsciiText(*ptr);

        auto formatStore = FormatStore(fmtetc, stgmed);
        return Range(formatStore);
    }

    private Range getWideString()
    {
        auto ptr = _dragData._data.peek!string;
        if (ptr is null)
            return Range();

        FORMATETC fmtetc = { CF_TEXT, null, DVASPECT.DVASPECT_CONTENT, -1, TYMED.TYMED_HGLOBAL };
        STGMEDIUM stgmed = { TYMED.TYMED_HGLOBAL };

        // format matches, copy text data to global memory
        stgmed.hGlobal = copyWideText(*ptr);

        auto formatStore = FormatStore(fmtetc, stgmed);
        return Range(formatStore);
    }

    // Copy text to an HGLOBAL and return it
    private static HGLOBAL copyAsciiText(string text)
    {
        immutable bytes = text.memSizeOf;

        HGLOBAL hMem = GlobalAlloc(GHND, bytes + char.sizeof);  // null terminator
        auto ptr = cast(char*)GlobalLock(hMem);
        scope(exit) GlobalUnlock(hMem);

        // copy the text and null-terminate it
        memcpy(ptr, text.ptr, bytes);
        ptr[text.length] = '\0';
        return hMem;
    }

    // ditto
    private static HGLOBAL copyWideText(string text)
    {
        auto data = text.toWideString();
        immutable bytes = data.memSizeOf;

        HGLOBAL hMem = GlobalAlloc(GHND, bytes + wchar.sizeof);  // null terminator
        auto ptr = cast(wchar*)GlobalLock(hMem);
        scope(exit) GlobalUnlock(hMem);

        // copy the text and null-terminate it
        memcpy(ptr, data.ptr, bytes);
        ptr[data.length] = '\0';
        return hMem;
    }

private:
    DragData _dragData;
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
        scope(exit) ReleaseStgMedium(&stgmed);

        // we asked for the data as a HGLOBAL, so access it appropriately
        auto data = cast(char*)GlobalLock(stgmed.hGlobal);
        scope(exit) GlobalUnlock(stgmed.hGlobal);

        string result = to!string(data);
        return result;
    }

private:
    private void readData(T)(FORMATETC* fmtetc, STGMEDIUM* stgmed)
    {
        enforce(_dataObject.QueryGetData(fmtetc) == S_OK,
                format("Drop data does not contain any data of type '%s'.", T.stringof));

        enforce(_dataObject.GetData(fmtetc, stgmed) == S_OK,
                format("Could not read drop data of type '%s'.", T.stringof));
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
        auto event = scoped!DropEvent(_widget, action, _dropData, dropEffect, position, keyMod, timeMsec);
        Dispatch._dispatchInternalEvent(_widget, event);

        if (event._acceptDrop)
            *pdwEffect = cast(DWORD)event._dropEffect;
        else
            *pdwEffect = DROPEFFECT.DROPEFFECT_NONE;

        return S_OK;
    }

    private HRESULT dispatchLeaveEvent()
    {
        TimeMsec timeMsec = getTclTime();

        assert(_dropData._dataObject !is null);
        auto event = scoped!DropEvent(_widget, DropAction.leave, timeMsec);
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
            keyMod += KeyMod.control;

        if (grfKeyState & MK_ALT)
            keyMod += KeyMod.alt;

        if (grfKeyState & MK_SHIFT)
            keyMod += KeyMod.shift;

        if (grfKeyState & MK_LBUTTON)
            keyMod += KeyMod.mouse_left;

        if (grfKeyState & MK_MBUTTON)
            keyMod += KeyMod.mouse_middle;

        if (grfKeyState & MK_RBUTTON)
            keyMod += KeyMod.mouse_right;

        return keyMod;
    }

private:
    Widget _widget;
    DropData _dropData;
    DWORD _dwEffect;
}

/** Get a new drop target. */
DropTarget createDropTarget(Widget widget)
{
    return newCom!DropTarget(widget);
}

wchar[] toWideString(string input)
{
    if (input.length == 0)
        return null;

    enum CP_UTF8 = 65001;
    enum convType = 0;
    auto len = MultiByteToWideChar(CP_UTF8, convType, input.ptr, cast(int)input.length, null, 0);
    if (len == 0)
        return null;

    auto buf = new wchar[](len);
    len = MultiByteToWideChar(CP_UTF8, convType, input.ptr, cast(int)input.length, buf.ptr, len);
    if (len == 0)
        return null;

    return buf;
}
