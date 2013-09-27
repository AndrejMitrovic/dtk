/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.platform.win32.com;


extern(C) void* gc_malloc(size_t sz, uint ba = 0, const TypeInfo ti=null);

C _newCom(C, T...)(T arguments)
{
	// avoid special casing in _d_newclass, where COM objects are not garbage collected
	size_t size = C.classinfo.init.length;
	void* p = gc_malloc(size, 1, C.classinfo); // BlkAttr.FINALIZE
	memcpy(p, C.classinfo.init.ptr, size);
	C c = cast(C) p;
	static if(arguments.length || __traits(compiles,c.__ctor(arguments)))
		c.__ctor(arguments);
	return c;
}

C newCom(C, T...)(T arguments) if(is(C : ComObject) && T.length > 0)
{
    return _newCom!C(arguments);
}

@property C newCom(C)() if(is(C : ComObject))
{
	return _newCom!C();
}

class ComObject : IUnknown
{
    /**
        Note: See Issue 4092, COM objects are allocated in the
        C heap instead of the GC:
        http://d.puremagic.com/issues/show_bug.cgi?id=4092
    */
	@disable new(size_t size)
	{
		assert(false); // should not be called because we don't have enough type info
		void* p = gc_malloc(size, 1, typeid(ComObject)); // BlkAttr.FINALIZE
		return p;
	}

    override HRESULT QueryInterface(in IID* riid, void** ppv)
	{
		if (*riid == IID_IUnknown)
		{
			*ppv = cast(void*)cast(IUnknown)this;
			AddRef();
			return S_OK;
		}
		*ppv = null;
		return E_NOINTERFACE;
	}

	override ULONG AddRef()
	{
		LONG lRef = InterlockedIncrement(&count);
		if(lRef == 1)
		{
			void* vthis = cast(void*) this;
			GC.addRoot(vthis);
		}
		return lRef;
	}

	override ULONG Release()
	{
		LONG lRef = InterlockedDecrement(&count);
		if (lRef == 0)
		{
			void* vthis = cast(void*) this;
			GC.removeRoot(vthis);
			return 0;
		}
		return cast(ULONG)lRef;
	}

	shared(LONG) _refCount;
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
