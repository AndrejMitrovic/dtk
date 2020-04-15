/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.platform.win32.defs;

version (Windows):

import dtk.imports;

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

export extern (C)
{
    const IID IID_IDropSource = {0x00000121, 0x0000, 0x0000, [0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46]};
    const IID IID_IDataObject = {0x0000010E, 0x0000, 0x0000, [0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46]};
    const IID IID_IDropTarget = {0x00000122, 0x0000, 0x0000, [0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46]};
    const IID IID_IUnknown = {0x00000000, 0x0000, 0x0000, [0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46]};

    //~ extern IID IID_IUnknown;
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
    //~ extern IID IID_IDataObject;
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
    //~ extern IID IID_IDropSource;
    //~ extern IID IID_IDropTarget;
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
    BYTE[1] tdData;
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
extern(Windows) BOOL FreeLibrary(HMODULE);
extern(Windows) FARPROC GetProcAddress(HMODULE hModule, LPCSTR lpProcName);
extern(Windows) BOOL GlobalUnlock(HGLOBAL hMem);

extern(Windows) UINT RegisterClipboardFormatW(LPCWSTR);
extern(Windows) DWORD GetLastError();

interface IDropSource : IUnknown
{
	HRESULT QueryContinueDrag(BOOL,DWORD);
	HRESULT GiveFeedback(DWORD);
}

enum : BOOL
{
	FALSE = 0,
	TRUE  = 1
}

enum DRAGDROP_S_CANCEL                      = 0x00040101;
enum DRAGDROP_S_DROP                        = 0x00040100;
enum DRAGDROP_S_USEDEFAULTCURSORS           = 0x00040102;

extern(Windows) HRESULT DoDragDrop(LPDATAOBJECT, LPDROPSOURCE, DWORD, PDWORD);

alias IDropSource LPDROPSOURCE;

enum DV_E_FORMATETC                         = 0x80040064;
enum DATA_E_FORMATETC = DV_E_FORMATETC;
enum DATA_S_SAMEFORMATETC                   = 0x00040130;

enum DATADIR
{
	DATADIR_GET = 1,
	DATADIR_SET
}

enum OLE_E_ADVISENOTSUPPORTED               = 0x80040003;

extern(Windows) HGLOBAL GlobalAlloc(UINT, DWORD);
extern(Windows) HGLOBAL GlobalDiscard(HGLOBAL);
extern(Windows) HGLOBAL GlobalFree(HGLOBAL);
extern(Windows) HGLOBAL GlobalHandle(PCVOID);
extern(Windows) VOID GlobalMemoryStatus(LPMEMORYSTATUS);
extern(Windows) HGLOBAL GlobalReAlloc(HGLOBAL, DWORD, UINT);
extern(Windows) DWORD GlobalSize(HGLOBAL);

enum UINT
	GMEM_FIXED       = 0,
	GMEM_MOVEABLE    = 0x0002,
	GMEM_ZEROINIT    = 0x0040,
	GPTR             = 0x0040,
	GHND             = 0x0042,
	GMEM_MODIFY      = 0x0080,  // used only for GlobalRealloc
	GMEM_VALID_FLAGS = 0x7F72;

extern(Windows) PVOID CoTaskMemAlloc(ULONG);

alias void* PCVOID;


// MSDN documents this, possibly erroneously, as Win2000+.
struct MEMORYSTATUS {
	DWORD dwLength;
	DWORD dwMemoryLoad;
	DWORD dwTotalPhys;
	DWORD dwAvailPhys;
	DWORD dwTotalPageFile;
	DWORD dwAvailPageFile;
	DWORD dwTotalVirtual;
	DWORD dwAvailVirtual;
}

alias MEMORYSTATUS* LPMEMORYSTATUS;

extern(Windows) void CoTaskMemFree(PVOID);
extern(Windows) int MultiByteToWideChar(UINT, DWORD, LPCSTR, int, LPWSTR, int);
extern(Windows) DWORD GetCurrentProcessId();
extern(Windows) DWORD GetFileAttributesW(LPCWSTR);

enum FILE_ATTRIBUTE_DIRECTORY = 0x00000010;

alias void va_list;

extern(Windows) DWORD FormatMessageA(DWORD, PCVOID, DWORD, DWORD, LPSTR, DWORD, va_list*);
extern(Windows) DWORD FormatMessageW(DWORD, PCVOID, DWORD, DWORD, LPWSTR, DWORD, va_list*);

const DWORD
	FORMAT_MESSAGE_ALLOCATE_BUFFER = 0x0100,
	FORMAT_MESSAGE_IGNORE_INSERTS  = 0x0200,
	FORMAT_MESSAGE_FROM_STRING     = 0x0400,
	FORMAT_MESSAGE_FROM_HMODULE    = 0x0800,
	FORMAT_MESSAGE_FROM_SYSTEM     = 0x1000,
	FORMAT_MESSAGE_ARGUMENT_ARRAY  = 0x2000;


string sysErrorString(uint errcode) @trusted
{
    char[] result;
    char* buffer;
    DWORD r;

    r = FormatMessageA(
            FORMAT_MESSAGE_ALLOCATE_BUFFER |
            FORMAT_MESSAGE_FROM_SYSTEM |
            FORMAT_MESSAGE_IGNORE_INSERTS,
            null,
            errcode,
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
            cast(LPTSTR)&buffer,
            0,
            null);

    /* Remove \r\n from error string */
    if (r >= 2)
        r -= 2;

    /* Create 0 terminated copy on GC heap because fromMBSz()
     * may return it.
     */
    result = new char[r + 1];
    result[0 .. r] = buffer[0 .. r];
    result[r] = 0;

    LocalFree(cast(HLOCAL)buffer);

    auto res = fromMBSz(cast(immutable)result.ptr);

    return res;
}

// Primary language identifiers
enum : USHORT {
	LANG_NEUTRAL,
	LANG_ARABIC,
	LANG_BULGARIAN,
	LANG_CATALAN,
	LANG_CHINESE,
	LANG_CZECH,
	LANG_DANISH,
	LANG_GERMAN,
	LANG_GREEK,
	LANG_ENGLISH,
	LANG_SPANISH,
	LANG_FINNISH,
	LANG_FRENCH,
	LANG_HEBREW,
	LANG_HUNGARIAN,
	LANG_ICELANDIC,
	LANG_ITALIAN,
	LANG_JAPANESE,
	LANG_KOREAN,
	LANG_DUTCH,
	LANG_NORWEGIAN,
	LANG_POLISH,
	LANG_PORTUGUESE,    // = 0x16
	LANG_ROMANIAN          = 0x18,
	LANG_RUSSIAN,
	LANG_CROATIAN,      // = 0x1A
	LANG_SERBIAN           = 0x1A,
	LANG_BOSNIAN           = 0x1A,
	LANG_SLOVAK,
	LANG_ALBANIAN,
	LANG_SWEDISH,
	LANG_THAI,
	LANG_TURKISH,
	LANG_URDU,
	LANG_INDONESIAN,
	LANG_UKRAINIAN,
	LANG_BELARUSIAN,
	LANG_SLOVENIAN,
	LANG_ESTONIAN,
	LANG_LATVIAN,
	LANG_LITHUANIAN,    // = 0x27
	LANG_FARSI             = 0x29,
	LANG_PERSIAN           = 0x29,
	LANG_VIETNAMESE,
	LANG_ARMENIAN,
	LANG_AZERI,
	LANG_BASQUE,
	LANG_LOWER_SORBIAN, // = 0x2E
	LANG_UPPER_SORBIAN     = 0x2E,
	LANG_MACEDONIAN,    // = 0x2F
	LANG_TSWANA            = 0x32,
	LANG_XHOSA             = 0x34,
	LANG_ZULU,
	LANG_AFRIKAANS,
	LANG_GEORGIAN,
	LANG_FAEROESE,
	LANG_HINDI,
	LANG_MALTESE,
	LANG_SAMI,
	LANG_IRISH,         // = 0x3C
	LANG_MALAY             = 0x3E,
	LANG_KAZAK,
	LANG_KYRGYZ,
	LANG_SWAHILI,       // = 0x41
	LANG_UZBEK             = 0x43,
	LANG_TATAR,
	LANG_BENGALI,
	LANG_PUNJABI,
	LANG_GUJARATI,
	LANG_ORIYA,
	LANG_TAMIL,
	LANG_TELUGU,
	LANG_KANNADA,
	LANG_MALAYALAM,
	LANG_ASSAMESE,
	LANG_MARATHI,
	LANG_SANSKRIT,
	LANG_MONGOLIAN,
	LANG_TIBETAN,
	LANG_WELSH,
	LANG_KHMER,
	LANG_LAO,           // = 0x54
	LANG_GALICIAN          = 0x56,
	LANG_KONKANI,
	LANG_MANIPURI,
	LANG_SINDHI,
	LANG_SYRIAC,
	LANG_SINHALESE,     // = 0x5B
	LANG_INUKTITUT         = 0x5D,
	LANG_AMHARIC,
	LANG_TAMAZIGHT,
	LANG_KASHMIRI,
	LANG_NEPALI,
	LANG_FRISIAN,
	LANG_PASHTO,
	LANG_FILIPINO,
	LANG_DIVEHI,        // = 0x65
	LANG_HAUSA             = 0x68,
	LANG_YORUBA            = 0x6A,
	LANG_QUECHUA,
	LANG_SOTHO,
	LANG_BASHKIR,
	LANG_LUXEMBOURGISH,
	LANG_GREENLANDIC,
	LANG_IGBO,          // = 0x70
	LANG_TIGRIGNA          = 0x73,
	LANG_YI                = 0x78,
	LANG_MAPUDUNGUN        = 0x7A,
	LANG_MOHAWK            = 0x7C,
	LANG_BRETON            = 0x7E,
	LANG_UIGHUR            = 0x80,
	LANG_MAORI,
	LANG_OCCITAN,
	LANG_CORSICAN,
	LANG_ALSATIAN,
	LANG_YAKUT,
	LANG_KICHE,
	LANG_KINYARWANDA,
	LANG_WOLOF,         // = 0x88
	LANG_DARI              = 0x8C,
	LANG_MALAGASY,      // = 0x8D

	LANG_SERBIAN_NEUTRAL   = 0x7C1A,
	LANG_BOSNIAN_NEUTRAL   = 0x781A,

	LANG_INVARIANT         = 0x7F
}

WORD MAKELANGID(USHORT p, USHORT s) { return cast(WORD)((s << 10) | p); }


// Sublanguage identifiers
enum : USHORT {
	SUBLANG_NEUTRAL,
	SUBLANG_DEFAULT,
	SUBLANG_SYS_DEFAULT,
	SUBLANG_CUSTOM_DEFAULT,                  // =  3
	SUBLANG_UI_CUSTOM_DEFAULT                   =  3,
	SUBLANG_CUSTOM_UNSPECIFIED,              // =  4

	SUBLANG_AFRIKAANS_SOUTH_AFRICA              =  1,
	SUBLANG_ALBANIAN_ALBANIA                    =  1,
	SUBLANG_ALSATIAN_FRANCE                     =  1,
	SUBLANG_AMHARIC_ETHIOPIA                    =  1,

	SUBLANG_ARABIC_SAUDI_ARABIA                 =  1,
	SUBLANG_ARABIC_IRAQ,
	SUBLANG_ARABIC_EGYPT,
	SUBLANG_ARABIC_LIBYA,
	SUBLANG_ARABIC_ALGERIA,
	SUBLANG_ARABIC_MOROCCO,
	SUBLANG_ARABIC_TUNISIA,
	SUBLANG_ARABIC_OMAN,
	SUBLANG_ARABIC_YEMEN,
	SUBLANG_ARABIC_SYRIA,
	SUBLANG_ARABIC_JORDAN,
	SUBLANG_ARABIC_LEBANON,
	SUBLANG_ARABIC_KUWAIT,
	SUBLANG_ARABIC_UAE,
	SUBLANG_ARABIC_BAHRAIN,
	SUBLANG_ARABIC_QATAR,                    // = 16

	SUBLANG_ARMENIAN_ARMENIA                    =  1,
	SUBLANG_ASSAMESE_INDIA                      =  1,

	SUBLANG_AZERI_LATIN                         =  1,
	SUBLANG_AZERI_CYRILLIC,                  // =  2

	SUBLANG_BASHKIR_RUSSIA                      =  1,
	SUBLANG_BASQUE_BASQUE                       =  1,
	SUBLANG_BELARUSIAN_BELARUS                  =  1,
	SUBLANG_BENGALI_INDIA                       =  1,

	SUBLANG_BOSNIAN_BOSNIA_HERZEGOVINA_LATIN    =  5,
	SUBLANG_BOSNIAN_BOSNIA_HERZEGOVINA_CYRILLIC =  8,

	SUBLANG_BRETON_FRANCE                       =  1,
	SUBLANG_BULGARIAN_BULGARIA                  =  1,
	SUBLANG_CATALAN_CATALAN                     =  1,

	SUBLANG_CHINESE_TRADITIONAL                 =  1,
	SUBLANG_CHINESE_SIMPLIFIED,
	SUBLANG_CHINESE_HONGKONG,
	SUBLANG_CHINESE_SINGAPORE,
	SUBLANG_CHINESE_MACAU,                   // =  5

	SUBLANG_CORSICAN_FRANCE                     =  1,

	SUBLANG_CROATIAN_CROATIA                    =  1,
	SUBLANG_CROATIAN_BOSNIA_HERZEGOVINA_LATIN   =  4,

	SUBLANG_CZECH_CZECH_REPUBLIC                =  1,
	SUBLANG_DANISH_DENMARK                      =  1,
	SUBLANG_DIVEHI_MALDIVES                     =  1,

	SUBLANG_DUTCH                               =  1,
	SUBLANG_DUTCH_BELGIAN,                   // =  2

	SUBLANG_ENGLISH_US                          =  1,
	SUBLANG_ENGLISH_UK,
	SUBLANG_ENGLISH_AUS,
	SUBLANG_ENGLISH_CAN,
	SUBLANG_ENGLISH_NZ,
	SUBLANG_ENGLISH_EIRE,                    // =  6
	SUBLANG_ENGLISH_IRELAND                     =  6,
	SUBLANG_ENGLISH_SOUTH_AFRICA,
	SUBLANG_ENGLISH_JAMAICA,
	SUBLANG_ENGLISH_CARIBBEAN,
	SUBLANG_ENGLISH_BELIZE,
	SUBLANG_ENGLISH_TRINIDAD,
	SUBLANG_ENGLISH_ZIMBABWE,
	SUBLANG_ENGLISH_PHILIPPINES,             // = 13
	SUBLANG_ENGLISH_INDIA                       = 16,
	SUBLANG_ENGLISH_MALAYSIA,
	SUBLANG_ENGLISH_SINGAPORE,               // = 18

	SUBLANG_ESTONIAN_ESTONIA                    =  1,
	SUBLANG_FAEROESE_FAROE_ISLANDS              =  1,
	SUBLANG_FILIPINO_PHILIPPINES                =  1,
	SUBLANG_FINNISH_FINLAND                     =  1,

	SUBLANG_FRENCH                              =  1,
	SUBLANG_FRENCH_BELGIAN,
	SUBLANG_FRENCH_CANADIAN,
	SUBLANG_FRENCH_SWISS,
	SUBLANG_FRENCH_LUXEMBOURG,
	SUBLANG_FRENCH_MONACO,                   // =  6

	SUBLANG_FRISIAN_NETHERLANDS                 =  1,
	SUBLANG_GALICIAN_GALICIAN                   =  1,
	SUBLANG_GEORGIAN_GEORGIA                    =  1,

	SUBLANG_GERMAN                              =  1,
	SUBLANG_GERMAN_SWISS,
	SUBLANG_GERMAN_AUSTRIAN,
	SUBLANG_GERMAN_LUXEMBOURG,
	SUBLANG_GERMAN_LIECHTENSTEIN,            // =  5

	SUBLANG_GREEK_GREECE                        =  1,
	SUBLANG_GREENLANDIC_GREENLAND               =  1,
	SUBLANG_GUJARATI_INDIA                      =  1,
	SUBLANG_HAUSA_NIGERIA                       =  1,
	SUBLANG_HEBREW_ISRAEL                       =  1,
	SUBLANG_HINDI_INDIA                         =  1,
	SUBLANG_HUNGARIAN_HUNGARY                   =  1,
	SUBLANG_ICELANDIC_ICELAND                   =  1,
	SUBLANG_IGBO_NIGERIA                        =  1,
	SUBLANG_INDONESIAN_INDONESIA                =  1,

	SUBLANG_INUKTITUT_CANADA                    =  1,
	SUBLANG_INUKTITUT_CANADA_LATIN              =  1,

	SUBLANG_IRISH_IRELAND                       =  1,

	SUBLANG_ITALIAN                             =  1,
	SUBLANG_ITALIAN_SWISS,                   // =  2

	SUBLANG_JAPANESE_JAPAN                      =  1,

	SUBLANG_KASHMIRI_INDIA                      =  2,
	SUBLANG_KASHMIRI_SASIA                      =  2,

	SUBLANG_KAZAK_KAZAKHSTAN                    =  1,
	SUBLANG_KHMER_CAMBODIA                      =  1,
	SUBLANG_KICHE_GUATEMALA                     =  1,
	SUBLANG_KINYARWANDA_RWANDA                  =  1,
	SUBLANG_KONKANI_INDIA                       =  1,
	SUBLANG_KOREAN                              =  1,
	SUBLANG_KYRGYZ_KYRGYZSTAN                   =  1,
	SUBLANG_LAO_LAO_PDR                         =  1,
	SUBLANG_LATVIAN_LATVIA                      =  1,

	SUBLANG_LITHUANIAN                          =  1,
	SUBLANG_LITHUANIAN_LITHUANIA                =  1,

	SUBLANG_LOWER_SORBIAN_GERMANY               =  1,
	SUBLANG_LUXEMBOURGISH_LUXEMBOURG            =  1,
	SUBLANG_MACEDONIAN_MACEDONIA                =  1,
	SUBLANG_MALAYALAM_INDIA                     =  1,
	SUBLANG_MALTESE_MALTA                       =  1,
	SUBLANG_MAORI_NEW_ZEALAND                   =  1,
	SUBLANG_MAPUDUNGUN_CHILE                    =  1,
	SUBLANG_MARATHI_INDIA                       =  1,
	SUBLANG_MOHAWK_MOHAWK                       =  1,

	SUBLANG_MONGOLIAN_CYRILLIC_MONGOLIA         =  1,
	SUBLANG_MONGOLIAN_PRC,                   // =  2

	SUBLANG_MALAY_MALAYSIA                      =  1,
	SUBLANG_MALAY_BRUNEI_DARUSSALAM,         // =  2

	SUBLANG_NEPALI_NEPAL                        =  1,
	SUBLANG_NEPALI_INDIA,                    // =  2

	SUBLANG_NORWEGIAN_BOKMAL                    =  1,
	SUBLANG_NORWEGIAN_NYNORSK,               // =  2

	SUBLANG_OCCITAN_FRANCE                      =  1,
	SUBLANG_ORIYA_INDIA                         =  1,
	SUBLANG_PASHTO_AFGHANISTAN                  =  1,
	SUBLANG_PERSIAN_IRAN                        =  1,
	SUBLANG_POLISH_POLAND                       =  1,

	SUBLANG_PORTUGUESE_BRAZILIAN                =  1,
	SUBLANG_PORTUGUESE                          =  2,
	SUBLANG_PORTUGUESE_PORTUGAL,             // =  2

	SUBLANG_PUNJABI_INDIA                       =  1,

	SUBLANG_QUECHUA_BOLIVIA                     =  1,
	SUBLANG_QUECHUA_ECUADOR,
	SUBLANG_QUECHUA_PERU,                    // =  3

	SUBLANG_ROMANIAN_ROMANIA                    =  1,
	SUBLANG_ROMANSH_SWITZERLAND                 =  1,
	SUBLANG_RUSSIAN_RUSSIA                      =  1,

	SUBLANG_SAMI_NORTHERN_NORWAY                =  1,
	SUBLANG_SAMI_NORTHERN_SWEDEN,
	SUBLANG_SAMI_NORTHERN_FINLAND,           // =  3
	SUBLANG_SAMI_SKOLT_FINLAND                  =  3,
	SUBLANG_SAMI_INARI_FINLAND                  =  3,
	SUBLANG_SAMI_LULE_NORWAY,
	SUBLANG_SAMI_LULE_SWEDEN,
	SUBLANG_SAMI_SOUTHERN_NORWAY,
	SUBLANG_SAMI_SOUTHERN_SWEDEN,            // =  7

	SUBLANG_SANSKRIT_INDIA                      =  1,

	SUBLANG_SERBIAN_LATIN                       =  2,
	SUBLANG_SERBIAN_CYRILLIC,                // =  3
	SUBLANG_SERBIAN_BOSNIA_HERZEGOVINA_LATIN    =  6,
	SUBLANG_SERBIAN_BOSNIA_HERZEGOVINA_CYRILLIC =  7,

	SUBLANG_SINDHI_AFGHANISTAN                  =  2,
	SUBLANG_SINHALESE_SRI_LANKA                 =  1,
	SUBLANG_SOTHO_NORTHERN_SOUTH_AFRICA         =  1,
	SUBLANG_SLOVAK_SLOVAKIA                     =  1,
	SUBLANG_SLOVENIAN_SLOVENIA                  =  1,

	SUBLANG_SPANISH                             =  1,
	SUBLANG_SPANISH_MEXICAN,
	SUBLANG_SPANISH_MODERN,
	SUBLANG_SPANISH_GUATEMALA,
	SUBLANG_SPANISH_COSTA_RICA,
	SUBLANG_SPANISH_PANAMA,
	SUBLANG_SPANISH_DOMINICAN_REPUBLIC,
	SUBLANG_SPANISH_VENEZUELA,
	SUBLANG_SPANISH_COLOMBIA,
	SUBLANG_SPANISH_PERU,
	SUBLANG_SPANISH_ARGENTINA,
	SUBLANG_SPANISH_ECUADOR,
	SUBLANG_SPANISH_CHILE,
	SUBLANG_SPANISH_URUGUAY,
	SUBLANG_SPANISH_PARAGUAY,
	SUBLANG_SPANISH_BOLIVIA,
	SUBLANG_SPANISH_EL_SALVADOR,
	SUBLANG_SPANISH_HONDURAS,
	SUBLANG_SPANISH_NICARAGUA,
	SUBLANG_SPANISH_PUERTO_RICO,
	SUBLANG_SPANISH_US,                      // = 21

	SUBLANG_SWEDISH                             =  1,
	SUBLANG_SWEDISH_SWEDEN                      =  1,
	SUBLANG_SWEDISH_FINLAND,                 // =  2

	SUBLANG_SYRIAC                              =  1,
	SUBLANG_TAJIK_TAJIKISTAN                    =  1,
	SUBLANG_TAMAZIGHT_ALGERIA_LATIN             =  2,
	SUBLANG_TAMIL_INDIA                         =  1,
	SUBLANG_TATAR_RUSSIA                        =  1,
	SUBLANG_TELUGU_INDIA                        =  1,
	SUBLANG_THAI_THAILAND                       =  1,
	SUBLANG_TIBETAN_PRC                         =  1,
	SUBLANG_TIBETAN_BHUTAN                      =  2,
	SUBLANG_TIGRIGNA_ERITREA                    =  1,
	SUBLANG_TSWANA_SOUTH_AFRICA                 =  1,
	SUBLANG_TURKISH_TURKEY                      =  1,
	SUBLANG_TURKMEN_TURKMENISTAN                =  1,
	SUBLANG_UIGHUR_PRC                          =  1,
	SUBLANG_UKRAINIAN_UKRAINE                   =  1,
	SUBLANG_UPPER_SORBIAN_GERMANY               =  1,

	SUBLANG_URDU_PAKISTAN                       =  1,
	SUBLANG_URDU_INDIA,                      // =  2

	SUBLANG_UZBEK_LATIN                         =  1,
	SUBLANG_UZBEK_CYRILLIC,                  // =  2

	SUBLANG_VIETNAMESE_VIETNAM                  =  1,
	SUBLANG_WELSH_UNITED_KINGDOM                =  1,
	SUBLANG_WOLOF_SENEGAL                       =  1,
	SUBLANG_YORUBA_NIGERIA                      =  1,
	SUBLANG_XHOSA_SOUTH_AFRICA                  =  1,
	SUBLANG_YAKUT_RUSSIA                        =  1,
	SUBLANG_YI_PRC                              =  1,
	SUBLANG_ZULU_SOUTH_AFRICA                   =  1
}

extern(Windows) HLOCAL LocalFree(HLOCAL);
