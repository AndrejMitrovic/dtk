/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.platform.win32;

import core.sys.windows.windows;

extern (Windows):

WINOLEAPI OleInitialize(LPVOID pvReserved);
WINOLEAPI DoDragDrop(IDataObject pDataObject, IDropSource pDropSource, DWORD dwOKEffect, DWORD* pdwEffect);
WINOLEAPI RegisterDragDrop(HWND hwnd, IDropTarget pDropTarget);
WINOLEAPI RevokeDragDrop(HWND hwnd);
WINOLEAPI OleGetClipboard(IDataObject* ppDataObj);
WINOLEAPI OleSetClipboard(IDataObject pDataObj);
WINOLEAPI OleFlushClipboard();
WINOLEAPI CreateStreamOnHGlobal(HGLOBAL hGlobal, BOOL fDeleteOnRelease, LPSTREAM ppstm);
WINOLEAPI OleLoadPicture(IStream pStream, LONG lSize, BOOL fRunmode, IID* riid, void** ppv);
