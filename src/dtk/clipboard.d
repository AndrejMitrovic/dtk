/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.clipboard;

/+ @property Clipboard clipboard()
{
    return Clipboard.get();
} +/

// todo: add clipboard listener
struct Clipboard
{
    /+ @disable this();

    static Clipboard get()
    {
        IDataObject dataObject;
        enforce(OleGetClipboard(&dataObject) == S_OK);
        scope(exit) dataObject.Release;

        DropData dropData;
        dropData._dataObject = dataObject;

        //~ DropEffect dropEffect = cast(DropEffect)*pdwEffect;

        return Clipboard(dropData);
    }

    /**
        Check whether the drop data contains data of type $(D DataType).

        $(B Note:) You may $(B not) access this property during a
        $(D DropAction.leave) action.
    */
    @property bool hasData(DataType)()
    {
        return _dropData.hasData!DataType();
    }

    /**
        Check whether the drag & drop data is movable.
        Movable implies the data is copyable, moving the data
        has the semantic meaning defined by the source of the
        drag & drop operation.

        Typically, when moving data the source will copy the data
        and then delete the source of the data. This is typically
        equivalent to a Cut & Paste operation in a text editor.

        $(B Note:) You may $(B not) access this property during a
        $(D DropAction.leave) action.
    */
    @property bool canMoveData()
    {
        return (_dropEffect & DropEffect.move) == DropEffect.move;
    }

    /**
        Check whether the drag & drop data is copyable.

        $(B Note:) You may $(B not) access this property during a
        $(D DropAction.leave) action.
    */
    @property bool canCopyData()
    {
        return (_dropEffect & DropEffect.copy) == DropEffect.copy;
    }

    /**
        Move the data of type $(D DataType) from source and return it.

        $(B Note:) You may $(B not) access this function during a
        $(D DropAction.leave) action.
    */
    DataType moveData(DataType)()
    {
        enforce(canMoveData, "Source does not allow data to be moved.");

        scope(success)
        {
            _dropEffect = DropEffect.move;
            _acceptDrop = true;
        }

        return _dropData.getData!DataType();
    }

    /**
        Copy the data of type $(D DataType) from source and return it.

        $(B Note:) You may $(B not) access this function during a
        $(D DropAction.leave) action.
    */
    DataType copyData(DataType)()
    {
        enforce(canCopyData, "Source does not allow data to be copied.");

        scope(success)
        {
            _dropEffect = DropEffect.copy;
            _acceptDrop = true;
        }

        return _dropData.getData!DataType();
    }

private:
    DropData _dropData; +/
}
