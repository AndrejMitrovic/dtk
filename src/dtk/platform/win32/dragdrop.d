/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.platform.win32.dragdrop;

import core.atomic;
import core.memory;
import core.time;

import std.exception;
import std.stdio;
import std.range;
import std.traits;
import std.typecons;
import std.variant;

import dtk.app;
import dtk.dispatch;
import dtk.dragdrop;
import dtk.event;
import dtk.geometry;
import dtk.interpreter;
import dtk.types;
import dtk.utils;

import dtk.platform.win32.defs;
import dtk.platform.win32.com;

import dtk.widgets.widget;
import dtk.widgets.window;

private static FORMATETC _fmtText = { CF_TEXT, null, DVASPECT.DVASPECT_CONTENT, -1, TYMED.TYMED_HGLOBAL };
private static FORMATETC _fmtUniText = { CF_UNICODETEXT, null, DVASPECT.DVASPECT_CONTENT, -1, TYMED.TYMED_HGLOBAL };
private static FORMATETC _dtkFormat;

private static DWORD _processID;

static void _initDragDrop()
{
    auto res = RegisterClipboardFormatW("dtk_drag_drop_format");
    enforce(res != 0, format("RegisterClipboardFormat error: %s", to!string(GetLastError())));
    _dtkFormat.cfFormat = cast(CLIPFORMAT)res;
    _dtkFormat.ptd = null;
    _dtkFormat.dwAspect = DVASPECT.DVASPECT_CONTENT;
    _dtkFormat.lindex = -1;
    _dtkFormat.tymed = TYMED.TYMED_HGLOBAL;  // note: must be hglobal

    _processID = GetCurrentProcessId();
}

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
    DWORD _processID;
    DragData _dragData;
    alias _dragData this;
}

void nativeStartDragDrop(Widget widget, DragData inDragData)
{
    // todo: we can optimize and allocate COM classes on the stack
    IDropSource dropSource = newCom!DropSource(widget);
    dropSource.AddRef();
    scope(exit) dropSource.Release();

    // todo: we can optimize and allocate COM classes on the stack
    auto dragData = NativeDragData(_processID, inDragData);
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
    TimeMsec timeMsec = getTclTime();

    if (dwResult == DRAGDROP_S_DROP)
    {
        DropEffect dropEffect = cast(DropEffect)dwEffect;
        auto event = scoped!DragEvent(widget, DragAction.drop, dropEffect, timeMsec);
        Dispatch._dispatchInternalEvent(widget, event);
    }
    else
    if (dwResult == DRAGDROP_S_CANCEL)
    {
        // todo: Once SendEvent/PostEvent are implemented we should use those functions.
        auto event = scoped!DragEvent(widget, DragAction.canceled, timeMsec);
        Dispatch._dispatchInternalEvent(widget, event);
    }
}

/**
    A DTK widget uses this drop source object to change state
    (e.g. mouse cursor, widget color, etc) based on entry/exit,
    and to determine if the drag/drop operation should be
    accepted or cancelled when some keyboard modifier
    has been pressed/released or when the escape key is hit.
*/
class DropSource : ComObject, IDropSource
{
    this(Widget widget)
    {
        _widget = widget;
    }

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
        bool escapePressed = cast(bool)fEscapePressed;
        auto keyMod = getKeyMod(grfKeyState);
        TimeMsec timeMsec = getTclTime();

        // todo: Once SendEvent/PostEvent are implemented we should use those functions.
        auto event = scoped!DragEvent(_widget, DragAction.keyChange, escapePressed, keyMod, timeMsec);
        Dispatch._dispatchInternalEvent(_widget, event);

        return event._dragState;
    }

    // Return either S_OK or DRAGDROP_S_USEDEFAULTCURSORS to instruct OLE to use the
    // default mouse cursor images
    extern (Windows)
    HRESULT GiveFeedback(DWORD dwEffect)
    {
        // dwEffect describes the value returned by the
        // most recent call to IDropTarget::DragEnter,
        // IDropTarget::DragOver, or IDropTarget::DragLeave.

        // For every call to either IDropTarget::DragEnter or
        // IDropTarget::DragOver, DoDragDrop calls
        // IDropSource::GiveFeedback, passing it the DROPEFFECT
        // value returned from the drop target call.

        // DoDragDrop calls IDropTarget::DragLeave when the
        // mouse has left the target window. Then, DoDragDrop
        // calls IDropSource::GiveFeedback and passes the
        // DROPEFFECT_NONE value in the dwEffect parameter.

        // The dwEffect parameter can include DROPEFFECT_SCROLL,
        // indicating that the source should put up the
        // drag-scrolling variation of the appropriate pointer.

        // IDropSource::GiveFeedback is responsible for changing the
        // cursor shape or for changing the highlighted source based
        // on the value of the dwEffect parameter.

        DropEffect dropEffect = cast(DropEffect)dwEffect;
        TimeMsec timeMsec = getTclTime();

        // todo: Once SendEvent/PostEvent are implemented we should use those functions.
        auto event = scoped!DragEvent(_widget, DragAction.feedback, dropEffect, timeMsec);
        Dispatch._dispatchInternalEvent(_widget, event);

        // todo: if a new cursor isn't set, then we'll return this.
        return DRAGDROP_S_USEDEFAULTCURSORS;
    }

private:
    Widget _widget;
}

private struct FormatStore
{
    FORMATETC fmtetc;
    STGMEDIUM stgmed;
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
class DataObject : ComObject, IDataObject
{
    this(NativeDragData dragData)
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
                break;
        }

        // note: cannot be in switch statement due to CT read requirement
        if (fmtetc.cfFormat == _dtkFormat.cfFormat)
            return getDragData();

        return Range();
    }

    private Range getDragData()
    {
        STGMEDIUM stgmed = { TYMED.TYMED_HGLOBAL };
        stgmed.hGlobal = copyDragData();

        auto formatStore = FormatStore(_dtkFormat, stgmed);
        return Range(formatStore);
    }

    private Range getAsciiString()
    {
        auto ptr = _dragData._data.peek!string;
        if (ptr is null)
            return Range();

        if (!(*ptr).isAsciiString)
            return Range();

        STGMEDIUM stgmed = { TYMED.TYMED_HGLOBAL };
        stgmed.hGlobal = copyAsciiText(*ptr);

        auto formatStore = FormatStore(_fmtText, stgmed);
        return Range(formatStore);
    }

    private Range getWideString()
    {
        auto ptr = _dragData._data.peek!string;
        if (ptr is null)
            return Range();

        STGMEDIUM stgmed = { TYMED.TYMED_HGLOBAL };
        stgmed.hGlobal = copyWideText(*ptr);

        auto formatStore = FormatStore(_fmtText, stgmed);
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

    private HGLOBAL copyDragData()
    {
        enum bytes = NativeDragData.sizeof;

        HGLOBAL hMem = GlobalAlloc(GHND, bytes);
        auto ptr = cast(NativeDragData*)GlobalLock(hMem);
        scope(exit) GlobalUnlock(hMem);

        memcpy(ptr, &_dragData, bytes);
        return hMem;
    }

private:
    NativeDragData _dragData;
}

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
        return _dataObject.QueryGetData(&_fmtText) == S_OK;
    }

    private bool hasWideString()
    {
        return _dataObject.QueryGetData(&_fmtUniText) == S_OK;
    }

    private bool hasDtkDragData(T)()
    {
        // if no dtk data, return early
        if (_dataObject.QueryGetData(&_dtkFormat) != S_OK)
            return false;

        STGMEDIUM stgmed;
        readData!NativeDragData(&_dtkFormat, &stgmed);
        scope(exit) ReleaseStgMedium(&stgmed);

        // we asked for the data as a HGLOBAL, so access it appropriately
        auto dragData = cast(NativeDragData*)GlobalLock(stgmed.hGlobal);
        scope(exit) GlobalUnlock(stgmed.hGlobal);

        // peek!() would return null on base classes and other
        // small mismatches such as int => long.
        return dragData._data.convertsTo!T;
    }

private:

    private string getAsciiString()
    {
        FORMATETC fmtetc = _fmtText;
        STGMEDIUM stgmed;

        readData!string(&fmtetc, &stgmed);
        scope(exit) ReleaseStgMedium(&stgmed);

        // we asked for the data as a HGLOBAL, so access it appropriately
        auto data = cast(char*)GlobalLock(stgmed.hGlobal);
        scope(exit) GlobalUnlock(stgmed.hGlobal);

        string result = to!string(data);
        return result;
    }

    private string getWideString()
    {
        FORMATETC fmtetc = _fmtUniText;
        STGMEDIUM stgmed;

        readData!string(&fmtetc, &stgmed);
        scope(exit) ReleaseStgMedium(&stgmed);

        // we asked for the data as a HGLOBAL, so access it appropriately
        auto data = cast(wchar*)GlobalLock(stgmed.hGlobal);
        scope(exit) GlobalUnlock(stgmed.hGlobal);

        string result = data.fromWStringz();
        return result;
    }

    // get the type that a dtk drag data supports
    private T getDtkDragData(T)()
    {
        STGMEDIUM stgmed;
        readData!NativeDragData(&_dtkFormat, &stgmed);
        scope(exit) ReleaseStgMedium(&stgmed);

        // we asked for the data as a HGLOBAL, so access it appropriately
        auto dragData = cast(NativeDragData*)GlobalLock(stgmed.hGlobal);
        scope(exit) GlobalUnlock(stgmed.hGlobal);

        /**
            We cannot transfer pointer data across process boundaries
            since they're not in the same address space.

            Todo: Provide a serialization method for objects to be able
            to transfer them across processes.
        */
        static if (hasIndirections!T)
        {
            enforce(dragData._processID == _processID,
                format("Cannot drag data of type '%s' with indirections across process boundaries.", T.stringof));
        }

        return dragData._data.get!T;
    }

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

private KeyMod getKeyMod(DWORD grfKeyState)
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
