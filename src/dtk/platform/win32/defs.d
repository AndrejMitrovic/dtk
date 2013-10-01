/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.platform.win32.defs;

/**
    This module contains a minimal set of the
    Win32 API to avoid huge build times.
 */

union LARGE_INTEGER
{
    struct
    {
        uint LowPart;
        int  HighPart;
    }
    long QuadPart;
}

union ULARGE_INTEGER
{
    struct
    {
        uint LowPart;
        uint HighPart;
    }
    ulong QuadPart;
}
alias ULARGE_INTEGER* PULARGE_INTEGER;

struct FILETIME {
    DWORD dwLowDateTime;
    DWORD dwHighDateTime;
}
alias FILETIME* PFILETIME, LPFILETIME;

alias uint ULONG;
alias ULONG *PULONG;
alias ushort USHORT;
alias USHORT *PUSHORT;
alias ubyte UCHAR;
alias UCHAR *PUCHAR;
alias char *PSZ;

alias void VOID;
alias char CHAR;
alias short SHORT;
alias int LONG;

alias long  LONGLONG;
alias ulong ULONGLONG;

alias CHAR*         LPCH,  LPSTR,  PCH,  PSTR;
alias const(CHAR)*  LPCCH, LPCSTR, PCCH, PCSTR;

alias wchar WCHAR;
alias WCHAR*        LPWCH,  LPWSTR,  PWCH,  PWSTR;
alias const(WCHAR)* LPCWCH, LPCWSTR, PCWCH, PCWSTR;

alias CHAR*         LPTCH,  LPTSTR,  PTCH,  PTSTR;
alias const(CHAR)*  LPCTCH, LPCTSTR, PCTCH, PCTSTR;

alias uint DWORD;
alias ulong DWORD64;
alias int BOOL;
alias ubyte BYTE;
alias ushort WORD;
alias float FLOAT;
alias FLOAT* PFLOAT;
alias BOOL*  LPBOOL,  PBOOL;
alias BYTE*  LPBYTE,  PBYTE;
alias int*   LPINT,   PINT;
alias WORD*  LPWORD,  PWORD;
alias int*   LPLONG;
alias DWORD* LPDWORD, PDWORD;
alias void*  LPVOID;
alias const(void)* LPCVOID;

alias int INT;
alias uint UINT;
alias uint* PUINT;

alias size_t SIZE_T;

// ULONG_PTR must be able to store a pointer as an integral type
version (Win64)
{
    alias  long INT_PTR;
    alias ulong UINT_PTR;
    alias  long LONG_PTR;
    alias ulong ULONG_PTR;
    alias  long * PINT_PTR;
    alias ulong * PUINT_PTR;
    alias  long * PLONG_PTR;
    alias ulong * PULONG_PTR;
}
else // Win32
{
    alias  int INT_PTR;
    alias uint UINT_PTR;
    alias  int LONG_PTR;
    alias uint ULONG_PTR;
    alias  int * PINT_PTR;
    alias uint * PUINT_PTR;
    alias  int * PLONG_PTR;
    alias uint * PULONG_PTR;
}

alias ULONG_PTR DWORD_PTR;

alias void *HANDLE;
alias void *PVOID;
alias HANDLE HGLOBAL;
alias HANDLE HLOCAL;
alias LONG HRESULT;
alias LONG SCODE;
alias HANDLE HINSTANCE;
alias HINSTANCE HMODULE;
alias HANDLE HWND;
alias HANDLE* PHANDLE;

alias HANDLE HGDIOBJ;
alias HANDLE HACCEL;
alias HANDLE HBITMAP;
alias HANDLE HBRUSH;
alias HANDLE HCOLORSPACE;
alias HANDLE HDC;
alias HANDLE HGLRC;
alias HANDLE HDESK;
alias HANDLE HENHMETAFILE;
alias HANDLE HFONT;
alias HANDLE HICON;
alias HANDLE HMENU;
alias HANDLE HMETAFILE;
alias HANDLE HPALETTE;
alias HANDLE HPEN;
alias HANDLE HRGN;
alias HANDLE HRSRC;
alias HANDLE HSTR;
alias HANDLE HTASK;
alias HANDLE HWINSTA;
alias HANDLE HKL;
alias HICON HCURSOR;

alias HANDLE HKEY;
alias HKEY *PHKEY;
alias DWORD ACCESS_MASK;
alias ACCESS_MASK *PACCESS_MASK;
alias ACCESS_MASK REGSAM;

version (Win64)
    alias INT_PTR function() FARPROC;
else
    alias int function() FARPROC;

alias UINT_PTR WPARAM;
alias LONG_PTR LPARAM;
alias LONG_PTR LRESULT;

alias DWORD   COLORREF;
alias DWORD   *LPCOLORREF;
alias WORD    ATOM;


alias WCHAR OLECHAR;
alias OLECHAR *LPOLESTR;
alias OLECHAR *LPCOLESTR;

enum
{
        rmm = 23,       // OLE 2 version number info
        rup = 639,
}

enum : int
{
        S_OK = 0,
        S_FALSE = 0x00000001,
        NOERROR = 0,
        E_NOTIMPL     = cast(int)0x80004001,
        E_NOINTERFACE = cast(int)0x80004002,
        E_POINTER     = cast(int)0x80004003,
        E_ABORT       = cast(int)0x80004004,
        E_FAIL        = cast(int)0x80004005,
        E_HANDLE      = cast(int)0x80070006,
        CLASS_E_NOAGGREGATION = cast(int)0x80040110,
        E_OUTOFMEMORY = cast(int)0x8007000E,
        E_INVALIDARG  = cast(int)0x80070057,
        E_UNEXPECTED  = cast(int)0x8000FFFF,
}

struct GUID {          // size is 16
    align(1):
        DWORD Data1;
        WORD  Data2;
        WORD  Data3;
        BYTE[8]  Data4;
}

enum
{
        CLSCTX_INPROC_SERVER    = 0x1,
        CLSCTX_INPROC_HANDLER   = 0x2,
        CLSCTX_LOCAL_SERVER     = 0x4,
        CLSCTX_INPROC_SERVER16  = 0x8,
        CLSCTX_REMOTE_SERVER    = 0x10,
        CLSCTX_INPROC_HANDLER16 = 0x20,
        CLSCTX_INPROC_SERVERX86 = 0x40,
        CLSCTX_INPROC_HANDLERX86 = 0x80,

        CLSCTX_INPROC = (CLSCTX_INPROC_SERVER|CLSCTX_INPROC_HANDLER),
        CLSCTX_ALL = (CLSCTX_INPROC_SERVER| CLSCTX_INPROC_HANDLER| CLSCTX_LOCAL_SERVER),
        CLSCTX_SERVER = (CLSCTX_INPROC_SERVER|CLSCTX_LOCAL_SERVER),
}

enum
{
       COINIT_APARTMENTTHREADED   = 0x2,
       COINIT_MULTITHREADED       = 0x0,
       COINIT_DISABLE_OLE1DDE     = 0x4,
       COINIT_SPEED_OVER_MEMORY   = 0x8
}
alias DWORD COINIT;
enum RPC_E_CHANGED_MODE = 0x80010106;

alias const(GUID) IID;
alias const(GUID) CLSID;

extern (C)
{
    extern IID IID_IUnknown;
    extern IID IID_IClassFactory;
    extern IID IID_IMarshal;
    extern IID IID_IMallocSpy;
    extern IID IID_IStdMarshalInfo;
    extern IID IID_IExternalConnection;
    extern IID IID_IMultiQI;
    extern IID IID_IEnumUnknown;
    extern IID IID_IBindCtx;
    extern IID IID_IEnumMoniker;
    extern IID IID_IRunnableObject;
    extern IID IID_IRunningObjectTable;
    extern IID IID_IPersist;
    extern IID IID_IPersistStream;
    extern IID IID_IMoniker;
    extern IID IID_IROTData;
    extern IID IID_IEnumString;
    extern IID IID_ISequentialStream;
    extern IID IID_IStream;
    extern IID IID_IEnumSTATSTG;
    extern IID IID_IStorage;
    extern IID IID_IPersistFile;
    extern IID IID_IPersistStorage;
    extern IID IID_ILockBytes;
    extern IID IID_IEnumFORMATETC;
    extern IID IID_IEnumSTATDATA;
    extern IID IID_IRootStorage;
    extern IID IID_IAdviseSink;
    extern IID IID_IAdviseSink2;
    extern IID IID_IDataObject;
    extern IID IID_IDataAdviseHolder;
    extern IID IID_IMessageFilter;
    extern IID IID_IRpcChannelBuffer;
    extern IID IID_IRpcProxyBuffer;
    extern IID IID_IRpcStubBuffer;
    extern IID IID_IPSFactoryBuffer;
    extern IID IID_IPropertyStorage;
    extern IID IID_IPropertySetStorage;
    extern IID IID_IEnumSTATPROPSTG;
    extern IID IID_IEnumSTATPROPSETSTG;
    extern IID IID_IFillLockBytes;
    extern IID IID_IProgressNotify;
    extern IID IID_ILayoutStorage;
    extern IID GUID_NULL;
    extern IID IID_IRpcChannel;
    extern IID IID_IRpcStub;
    extern IID IID_IStubManager;
    extern IID IID_IRpcProxy;
    extern IID IID_IProxyManager;
    extern IID IID_IPSFactory;
    extern IID IID_IInternalMoniker;
    extern IID IID_IDfReserved1;
    extern IID IID_IDfReserved2;
    extern IID IID_IDfReserved3;
    extern IID IID_IStub;
    extern IID IID_IProxy;
    extern IID IID_IEnumGeneric;
    extern IID IID_IEnumHolder;
    extern IID IID_IEnumCallback;
    extern IID IID_IOleManager;
    extern IID IID_IOlePresObj;
    extern IID IID_IDebug;
    extern IID IID_IDebugStream;
    extern IID IID_StdOle;
    extern IID IID_ICreateTypeInfo;
    extern IID IID_ICreateTypeInfo2;
    extern IID IID_ICreateTypeLib;
    extern IID IID_ICreateTypeLib2;
    extern IID IID_IDispatch;
    extern IID IID_IEnumVARIANT;
    extern IID IID_ITypeComp;
    extern IID IID_ITypeInfo;
    extern IID IID_ITypeInfo2;
    extern IID IID_ITypeLib;
    extern IID IID_ITypeLib2;
    extern IID IID_ITypeChangeEvents;
    extern IID IID_IErrorInfo;
    extern IID IID_ICreateErrorInfo;
    extern IID IID_ISupportErrorInfo;
    extern IID IID_IOleAdviseHolder;
    extern IID IID_IOleCache;
    extern IID IID_IOleCache2;
    extern IID IID_IOleCacheControl;
    extern IID IID_IParseDisplayName;
    extern IID IID_IOleContainer;
    extern IID IID_IOleClientSite;
    extern IID IID_IOleObject;
    extern IID IID_IOleWindow;
    extern IID IID_IOleLink;
    extern IID IID_IOleItemContainer;
    extern IID IID_IOleInPlaceUIWindow;
    extern IID IID_IOleInPlaceActiveObject;
    extern IID IID_IOleInPlaceFrame;
    extern IID IID_IOleInPlaceObject;
    extern IID IID_IOleInPlaceSite;
    extern IID IID_IContinue;
    extern IID IID_IViewObject;
    extern IID IID_IViewObject2;
    extern IID IID_IDropSource;
    extern IID IID_IDropTarget;
    extern IID IID_IEnumOLEVERB;
}

extern (Windows)
{
    DWORD   CoBuildVersion();

    int StringFromGUID2(GUID *rguid, LPOLESTR lpsz, int cbMax);

    /* init/uninit */

    HRESULT CoInitialize(LPVOID pvReserved);
    HRESULT CoInitializeEx(LPVOID pvReserved, DWORD dwCoInit);
    void    CoUninitialize();
    DWORD   CoGetCurrentProcess();


    HRESULT CoCreateInstance(const(CLSID) *rclsid, IUnknown UnkOuter,
                        DWORD dwClsContext, const(IID)* riid, void* ppv);

    //HINSTANCE CoLoadLibrary(LPOLESTR lpszLibName, BOOL bAutoFree);
    void    CoFreeLibrary(HINSTANCE hInst);
    void    CoFreeAllLibraries();
    void    CoFreeUnusedLibraries();

    interface IUnknown
    {
        HRESULT QueryInterface(const(IID)* riid, void** pvObject);
        ULONG AddRef();
        ULONG Release();
    }

    interface IClassFactory : IUnknown
    {
        HRESULT CreateInstance(IUnknown UnkOuter, IID* riid, void** pvObject);
        HRESULT LockServer(BOOL fLock);
    }
}



interface IDataObject : IUnknown
{
    HRESULT GetData(FORMATETC*, STGMEDIUM*);
    HRESULT GetDataHere(FORMATETC*, STGMEDIUM*);
    HRESULT QueryGetData(FORMATETC*);
    HRESULT GetCanonicalFormatEtc(FORMATETC*, FORMATETC*);
    HRESULT SetData(FORMATETC*, STGMEDIUM*, BOOL);
    HRESULT EnumFormatEtc(DWORD, IEnumFORMATETC*);
    HRESULT DAdvise(FORMATETC*, DWORD, IAdviseSink, PDWORD);
    HRESULT DUnadvise(DWORD);
    HRESULT EnumDAdvise(IEnumSTATDATA*);
}

struct FORMATETC
{
    CLIPFORMAT cfFormat;
    DVTARGETDEVICE* ptd;
    DWORD dwAspect;
    LONG lindex;
    DWORD tymed;
}


struct STGMEDIUM
{
    DWORD tymed;
    union
    {
        HBITMAP hBitmap;
        PVOID hMetaFilePict;
        HENHMETAFILE hEnhMetaFile;
        HGLOBAL hGlobal;
        LPWSTR lpszFileName;
        LPSTREAM pstm;
        LPSTORAGE pstg;
    }

    LPUNKNOWN pUnkForRelease;
}


interface IEnumFORMATETC : IUnknown
{
    HRESULT Next(ULONG, FORMATETC*, ULONG*);
    HRESULT Skip(ULONG);
    HRESULT Reset();
    HRESULT Clone(IEnumFORMATETC*);
}

interface IAdviseSink : IUnknown
{
    HRESULT QueryInterface(REFIID, PVOID*);
    ULONG AddRef();
    ULONG Release();
    void OnDataChange(FORMATETC*, STGMEDIUM*);
    void OnViewChange(DWORD, LONG);
    void OnRename(IMoniker);
    void OnSave();
    void OnClose();
}

interface IEnumSTATDATA : IUnknown
{
    HRESULT Next(ULONG, STATDATA*, ULONG*);
    HRESULT Skip(ULONG);
    HRESULT Reset();
    HRESULT Clone(IEnumSTATDATA*);
}

alias WORD CLIPFORMAT;

struct DVTARGETDEVICE
{
    DWORD tdSize;
    WORD tdDriverNameOffset;
    WORD tdDeviceNameOffset;
    WORD tdPortNameOffset;
    WORD tdExtDevmodeOffset;
    BYTE tdData[1];
}


alias IStream LPSTREAM;

interface ISequentialStream : IUnknown
{
    HRESULT Read(void*, ULONG, ULONG*);
    HRESULT Write(void*, ULONG, ULONG*);
}

interface IStream : ISequentialStream
{
    HRESULT Seek(LARGE_INTEGER, DWORD, ULARGE_INTEGER*);
    HRESULT SetSize(ULARGE_INTEGER);
    HRESULT CopyTo(IStream, ULARGE_INTEGER, ULARGE_INTEGER*, ULARGE_INTEGER*);
    HRESULT Commit(DWORD);
    HRESULT Revert();
    HRESULT LockRegion(ULARGE_INTEGER, ULARGE_INTEGER, DWORD);
    HRESULT UnlockRegion(ULARGE_INTEGER, ULARGE_INTEGER, DWORD);
    HRESULT Stat(STATSTG*, DWORD);
    HRESULT Clone(LPSTREAM*);
}

alias IStorage LPSTORAGE;

alias IUnknown LPUNKNOWN;

alias GUID* REFGUID, REFIID, REFCLSID, REFFMTID;

interface IMoniker : IPersistStream
{
    HRESULT BindToObject(IBindCtx, IMoniker, REFIID, PVOID*);
    HRESULT BindToStorage(IBindCtx, IMoniker, REFIID, PVOID*);
    HRESULT Reduce(IBindCtx, DWORD, IMoniker*, IMoniker*);
    HRESULT ComposeWith(IMoniker, BOOL, IMoniker*);
    HRESULT Enum(BOOL, IEnumMoniker*);
    HRESULT IsEqual(IMoniker);
    HRESULT Hash(PDWORD);
    HRESULT IsRunning(IBindCtx, IMoniker, IMoniker);
    HRESULT GetTimeOfLastChange(IBindCtx, IMoniker, LPFILETIME);
    HRESULT Inverse(IMoniker*);
    HRESULT CommonPrefixWith(IMoniker, IMoniker*);
    HRESULT RelativePathTo(IMoniker, IMoniker*);
    HRESULT GetDisplayName(IBindCtx, IMoniker, LPOLESTR*);
    HRESULT ParseDisplayName(IBindCtx, IMoniker, LPOLESTR, ULONG*, IMoniker*);
    HRESULT IsSystemMoniker(PDWORD);
}

interface IPersist : IUnknown
{
    HRESULT GetClassID(CLSID*);
}

interface IPersistStream : IPersist
{
    HRESULT IsDirty();
    HRESULT Load(IStream);
    HRESULT Save(IStream, BOOL);
    HRESULT GetSizeMax(PULARGE_INTEGER);
}

struct STATDATA
{
    FORMATETC formatetc;
    DWORD grfAdvf;
    IAdviseSink pAdvSink;
    DWORD dwConnection;
}


struct  STATSTG
{
    LPOLESTR pwcsName;
    DWORD type;
    ULARGE_INTEGER cbSize;
    FILETIME mtime;
    FILETIME ctime;
    FILETIME atime;
    DWORD grfMode;
    DWORD grfLocksSupported;
    CLSID clsid;
    DWORD grfStateBits;
    DWORD reserved;
}


interface IStorage : IUnknown
{
    HRESULT CreateStream(LPCWSTR, DWORD, DWORD, DWORD, IStream);
    HRESULT OpenStream(LPCWSTR, PVOID, DWORD, DWORD, IStream);
    HRESULT CreateStorage(LPCWSTR, DWORD, DWORD, DWORD, IStorage);
    HRESULT OpenStorage(LPCWSTR, IStorage, DWORD, SNB, DWORD, IStorage);
    HRESULT CopyTo(DWORD, IID*, SNB, IStorage);
    HRESULT MoveElementTo(LPCWSTR, IStorage, LPCWSTR, DWORD);
    HRESULT Commit(DWORD);
    HRESULT Revert();
    HRESULT EnumElements(DWORD, PVOID, DWORD, IEnumSTATSTG);
    HRESULT DestroyElement(LPCWSTR);
    HRESULT RenameElement(LPCWSTR, LPCWSTR);
    HRESULT SetElementTimes(LPCWSTR, FILETIME*, FILETIME*, FILETIME*);
    HRESULT SetClass(REFCLSID);
    HRESULT SetStateBits(DWORD, DWORD);
    HRESULT Stat(STATSTG*, DWORD);
}

interface IBindCtx : IUnknown
{
    HRESULT RegisterObjectBound(LPUNKNOWN);
    HRESULT RevokeObjectBound(LPUNKNOWN);
    HRESULT ReleaseBoundObjects();
    HRESULT SetBindOptions(LPBIND_OPTS);
    HRESULT GetBindOptions(LPBIND_OPTS);
    HRESULT GetRunningObjectTable(IRunningObjectTable*);
    HRESULT RegisterObjectParam(LPOLESTR, IUnknown);
    HRESULT GetObjectParam(LPOLESTR, IUnknown*);
    HRESULT EnumObjectParam(IEnumString*);
    HRESULT RevokeObjectParam(LPOLESTR);
}

interface IEnumMoniker : IUnknown
{
    HRESULT Next(ULONG, IMoniker*, ULONG*);
    HRESULT Skip(ULONG);
    HRESULT Reset();
    HRESULT Clone(IEnumMoniker*);
}

alias OLECHAR** SNB;

interface IEnumSTATSTG : IUnknown
{
    HRESULT Next(ULONG, STATSTG*, ULONG*);
    HRESULT Skip(ULONG);
    HRESULT Reset();
    HRESULT Clone(IEnumSTATSTG*);
}

alias BIND_OPTS* LPBIND_OPTS;

struct BIND_OPTS
{
    DWORD cbStruct;
    DWORD grfFlags;
    DWORD grfMode;
    DWORD dwTickCountDeadline;
}


interface IRunningObjectTable : IUnknown
{
    HRESULT Register(DWORD, LPUNKNOWN, LPMONIKER, PDWORD);
    HRESULT Revoke(DWORD);
    HRESULT IsRunning(LPMONIKER);
    HRESULT GetObject(LPMONIKER, LPUNKNOWN*);
    HRESULT NoteChangeTime(DWORD, LPFILETIME);
    HRESULT GetTimeOfLastChange(LPMONIKER, LPFILETIME);
    HRESULT EnumRunning(IEnumMoniker*);
}

interface IEnumString : IUnknown
{
    HRESULT Next(ULONG, LPOLESTR*, ULONG*);
    HRESULT Skip(ULONG);
    HRESULT Reset();
    HRESULT Clone(IEnumString*);
}

alias IMoniker LPMONIKER;

interface IDropTarget : IUnknown
{
    HRESULT DragEnter(LPDATAOBJECT, DWORD, POINTL, PDWORD);
    HRESULT DragOver(DWORD, POINTL, PDWORD);
    HRESULT DragLeave();
    HRESULT Drop(LPDATAOBJECT, DWORD, POINTL, PDWORD);
}

alias IDataObject LPDATAOBJECT;

alias POINT POINTL;

struct POINT
{
    LONG  x;
    LONG  y;
}

extern (Windows) HRESULT RegisterDragDrop(HWND, LPDROPTARGET);
extern (Windows) HRESULT RevokeDragDrop(HWND);

alias IDropTarget LPDROPTARGET;

enum DRAGDROP_E_ALREADYREGISTERED = 0x80040101;

enum DROPEFFECT
{
    DROPEFFECT_NONE   = 0,
    DROPEFFECT_COPY   = 1,
    DROPEFFECT_MOVE   = 2,
    DROPEFFECT_LINK   = 4,
    DROPEFFECT_SCROLL = 0x80000000
}


enum MK_CONTROL = 8;
enum MK_ALT     = 32;
enum MK_SHIFT   = 4;
enum MK_LBUTTON = 1;
enum MK_RBUTTON = 2;
enum MK_MBUTTON = 16;

extern (Windows) HRESULT OleInitialize(PVOID);
extern (Windows) void OleUninitialize();

enum DRAGDROP_E_NOTREGISTERED = 0x80040100;

enum {
	CF_TEXT = 1,
	CF_BITMAP,
	CF_METAFILEPICT,
	CF_SYLK,
	CF_DIF,
	CF_TIFF,
	CF_OEMTEXT,
	CF_DIB,
	CF_PALETTE,
	CF_PENDATA,
	CF_RIFF,
	CF_WAVE,
	CF_UNICODETEXT,
	CF_ENHMETAFILE,
	CF_HDROP,
	CF_LOCALE,
	CF_MAX, // = 17
	CF_OWNERDISPLAY   = 128,
	CF_DSPTEXT,
	CF_DSPBITMAP,
	CF_DSPMETAFILEPICT, // = 131
	CF_DSPENHMETAFILE = 142,
	CF_PRIVATEFIRST   = 512,
	CF_PRIVATELAST    = 767,
	CF_GDIOBJFIRST    = 768,
	CF_GDIOBJLAST     = 1023
}

enum DVASPECT {
	DVASPECT_CONTENT   = 1,
	DVASPECT_THUMBNAIL = 2,
	DVASPECT_ICON      = 4,
	DVASPECT_DOCPRINT  = 8
}

enum TYMED {
	TYMED_HGLOBAL  = 1,
	TYMED_FILE     = 2,
	TYMED_ISTREAM  = 4,
	TYMED_ISTORAGE = 8,
	TYMED_GDI      = 16,
	TYMED_MFPICT   = 32,
	TYMED_ENHMF    = 64,
	TYMED_NULL     = 0
}

extern(Windows) LPVOID GlobalLock(HGLOBAL);
extern(Windows) void ReleaseStgMedium(LPSTGMEDIUM);

alias STGMEDIUM* LPSTGMEDIUM;

extern(Windows) HMODULE LoadLibraryA(LPCSTR lpLibFileName);
extern(Windows) HMODULE LoadLibraryW(LPCWSTR lpLibFileName);
extern(Windows) FARPROC GetProcAddress(HMODULE hModule, LPCSTR lpProcName);
extern(Windows) BOOL GlobalUnlock(HGLOBAL hMem);
