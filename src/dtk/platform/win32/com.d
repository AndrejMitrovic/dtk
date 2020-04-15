/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.platform.win32.com;

version (Windows):

import dtk.imports;
import dtk.utils;

import dtk.platform.win32.defs;

C newCom(C, T...)(T arguments) if(is(C : ComObject) && T.length > 0)
{
    return _newCom!C(arguments);
}

@property C newCom(C)() if(is(C : ComObject))
{
	return _newCom!C();
}

extern(C) void* gc_malloc(size_t sz, uint ba = 0, const TypeInfo ti=null);

private C _newCom(C, T...)(T arguments)
{
    static assert(!__traits(isAbstractClass,C));

    // avoid special casing in _d_newclass, where COM objects are not garbage collected
    auto ini = typeid(C).initializer;
    size_t size = ini.length;
    void* p = gc_malloc(size, 1, typeid(C)); // BlkAttr.FINALIZE
    memcpy(p, ini.ptr, size);
    C c = cast(C) p;
    static if(arguments.length || __traits(compiles,c.__ctor(arguments)))
        c.__ctor(arguments);
    return c;
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
        // should not be called because we don't have enough type info
		assert(0);
        // GC.malloc(size, GC.BlkAttr.FINALIZE);
	}

    HRESULT QueryInterface(const(IID)* riid, void** ppv)
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

    ULONG AddRef()
    {
        LONG lRef = atomicOp!"+="(_refCount, 1);
        if (lRef == 1)
            GC.addRoot(cast(void*)this);

        return lRef;
    }

    ULONG Release()
    {
        LONG lRef = atomicOp!"-="(_refCount, 1);
        if (lRef == 0)
            GC.removeRoot(cast(void*)this);

        return cast(ULONG)lRef;
    }

	shared(LONG) _refCount;
}

/**
    Create a global memory buffer and store text contents to it.
    Return the handle to the memory buffer.
*/
HGLOBAL toGlobalMem(string text)
{
    // allocate and lock a global memory buffer. Make it fixed
    // data so we don't have to use GlobalLock
    char* ptr = cast(char*)GlobalAlloc(GMEM_FIXED, text.memSizeOf);

    // copy the string into the buffer
    ptr[0 .. text.length] = text[];

    return cast(HGLOBAL)ptr;
}

/**
    Duplicate the memory helt at the global memory handle,
    and return the handle to the duplicated memory.
*/
HGLOBAL dupGlobalMem(HGLOBAL hMem)
{
    // lock the source memory object
    PVOID source = GlobalLock(hMem);
    scope(exit) GlobalUnlock(hMem);

    // create a fixed global block - just
    // a regular lump of our process heap
    DWORD len = GlobalSize(hMem);
    PVOID dest = GlobalAlloc(GMEM_FIXED, len);
    memcpy(dest, source, len);

    return dest;
}

/** Perform a deep copy of a FORMATETC structure. */
FORMATETC deepDupFormatEtc(FORMATETC source)
{
    FORMATETC res;
    res = source;

    // duplicate memory for the DVTARGETDEVICE if necessary
    if (source.ptd)
    {
        res.ptd = cast(DVTARGETDEVICE*)CoTaskMemAlloc(DVTARGETDEVICE.sizeof);
        *(res.ptd) = *(source.ptd);
    }

    return res;
}
