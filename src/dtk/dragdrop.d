/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.dragdrop;

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
        return _widget._isDragDropRegistered;
    }

    /** Register the widget to accept drag & drop operations. */
    void register()
    {
        _dropTarget = new DropTarget(_widget);
        _register(_hwnd, _dropTarget);

        // widget must be unregistered before HWND becomes invalid.
        _widget._onAPIDestroyEvent ~= &unregister;
        //~ _widget.onDestroyEvent ~= &unregister;
        _widget._isDragDropRegistered = true;
    }

    /** Unregister the widget. */
    void unregister()
    {
        // printf("Unregistering %d\n", _hwnd);
        _unregister(_hwnd);
        _widget._isDragDropRegistered = false;
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

    static this()
    {
        OleInitialize(null);
    }

    static ~this()
    {
        OleUninitialize();
    }

private:
    DropTarget _dropTarget;
    Widget _widget;
    HWND _hwnd;
}

class DropTarget : IDropTarget
{
    this(Widget widget)
    {
        _widget = widget;
        _refCount = 1;
    }

    ULONG AddRef()
    {
        synchronized
        {
            ++_refCount;
            return _refCount;
        }
    }

    ULONG Release()
    {
        synchronized
        {
            if (_refCount)
                --_refCount;

            return _refCount;
        }
    }

    HRESULT QueryInterface(IID* riid, void** ppv)
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
        Dispatch._dispatchDragDropEvent(_widget, event);

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
        Dispatch._dispatchDragDropEvent(_widget, event);

        return S_OK;
    }

private:

    POINTL _lastPt;
    bool _lastDropAccepted;

    shared(LONG) _refCount;
    Widget _widget;
    IDataObject _pDataObject;
}

/+ class ComToDdataObject : IDataObject
{
	this(dfl.internal.wincom.IDataObject dataObj)
	{
		this.dataObj = dataObj;
		dataObj.AddRef();
	}


	~this()
	{
		dataObj.Release(); // Must get called...
	}


	private Data _getData(int id)
	{
		FORMATETC fmte;
		STGMEDIUM stgm;
		void[] mem;
		void* plock;

		fmte.cfFormat = cast(CLIPFORMAT)id;
		fmte.ptd = null;
		fmte.dwAspect = DVASPECT_CONTENT; // ?
		fmte.lindex = -1;
		fmte.tymed = TYMED_HGLOBAL; // ?

		if(S_OK != dataObj.GetData(&fmte, &stgm))
			throw new DflException("Unable to get data");


		void release()
		{
			//ReleaseStgMedium(&stgm);
			if(stgm.pUnkForRelease)
				stgm.pUnkForRelease.Release();
			else
				GlobalFree(stgm.hGlobal);
		}


		plock = GlobalLock(stgm.hGlobal);
		if(!plock)
		{
			release();
			throw new DflException("Error obtaining data");
		}

		mem = new ubyte[GlobalSize(stgm.hGlobal)];
		mem[] = plock[0 .. mem.length];
		GlobalUnlock(stgm.hGlobal);
		release();

		return DataFormats.getDataFromFormat(id, mem);
	}


	Data getData(Dstring fmt)
	{
		return _getData(DataFormats.getFormat(fmt).id);
	}


	Data getData(TypeInfo type)
	{
		return _getData(DataFormats.getFormatFromType(type).id);
	}


	Data getData(Dstring fmt, bool doConvert)
	{
		return getData(fmt); // ?
	}


	private bool _getDataPresent(int id)
	{
		FORMATETC fmte;

		fmte.cfFormat = cast(CLIPFORMAT)id;
		fmte.ptd = null;
		fmte.dwAspect = DVASPECT_CONTENT; // ?
		fmte.lindex = -1;
		fmte.tymed = TYMED_HGLOBAL; // ?

		return S_OK == dataObj.QueryGetData(&fmte);
	}


	bool getDataPresent(Dstring fmt)
	{
		return _getDataPresent(DataFormats.getFormat(fmt).id);
	}


	bool getDataPresent(TypeInfo type)
	{
		return _getDataPresent(DataFormats.getFormatFromType(type).id);
	}


	bool getDataPresent(Dstring fmt, bool canConvert)
	{
		return getDataPresent(fmt); // ?
	}


	Dstring[] getFormats()
	{
		IEnumFORMATETC fenum;
		FORMATETC fmte;
		Dstring[] result;
		ULONG nfetched = 1; // ?

		if(S_OK != dataObj.EnumFormatEtc(1, &fenum))
			throw new DflException("Unable to get formats");

		fenum.AddRef(); // ?
		for(;;)
		{
			if(S_OK != fenum.Next(1, &fmte, &nfetched))
				break;
			if(!nfetched)
				break;
			//cprintf("\t\t{getFormats:%d}\n", fmte.cfFormat);
			result ~= DataFormats.getFormat(fmte.cfFormat).name;
		}
		fenum.Release(); // ?

		return result;
	}


	// TO-DO: remove...
	deprecated final Dstring[] getFormats(bool onlyNative)
	{
		return getFormats();
	}


	private void _setData(int id, Data obj)
	{
		/+
		FORMATETC fmte;
		STGMEDIUM stgm;
		HANDLE hmem;
		void[] mem;
		void* pmem;

		mem = DataFormats.getClipboardValueFromData(id, obj);

		hmem = GlobalAlloc(GMEM_SHARE, mem.length);
		if(!hmem)
		{
			//cprintf("Unable to GlobalAlloc().\n");
			err_set:
			throw new DflException("Unable to set data");
		}
		pmem = GlobalLock(hmem);
		if(!pmem)
		{
			//cprintf("Unable to GlobalLock().\n");
			GlobalFree(hmem);
			goto err_set;
		}
		pmem[0 .. mem.length] = mem;
		GlobalUnlock(hmem);

		fmte.cfFormat = cast(CLIPFORMAT)id;
		fmte.ptd = null;
		fmte.dwAspect = DVASPECT_CONTENT; // ?
		fmte.lindex = -1;
		fmte.tymed = TYMED_HGLOBAL;

		stgm.tymed = TYMED_HGLOBAL;
		stgm.hGlobal = hmem;
		stgm.pUnkForRelease = null;

		// -dataObj- now owns the handle.
		HRESULT hr = dataObj.SetData(&fmte, &stgm, true);
		if(S_OK != hr)
		{
			//cprintf("Unable to IDataObject::SetData() = %d (0x%X).\n", hr, hr);
			// Failed, need to free it..
			GlobalFree(hmem);
			goto err_set;
		}
		+/
		// Don't set stuff in someone else's data object.
	}


	void setData(Data obj)
	{
		_setData(DataFormats.getFormatFromType(obj.info).id, obj);
	}


	void setData(Dstring fmt, Data obj)
	{
		_setData(DataFormats.getFormat(fmt).id, obj);
	}


	void setData(TypeInfo type, Data obj)
	{
		_setData(DataFormats.getFormatFromType(type).id, obj);
	}


	void setData(Dstring fmt, bool canConvert, Data obj)
	{
		setData(fmt, obj); // ?
	}


	final bool isSameDataObject(dfl.internal.wincom.IDataObject dataObj)
	{
		return dataObj is this.dataObj;
	}


	private:
	dfl.internal.wincom.IDataObject dataObj;
} +/
