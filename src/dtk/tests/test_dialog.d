module dtk.tests.test_dialog;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk;
import dtk.tests.globals;

unittest
{
    auto openFile = new OpenFileDialog();

    assert(openFile.fileTypes.empty);
    assert(openFile.defaultFileType == FileType.init);

    auto textFileType = FileType("Text Files", ".txt");

    openFile.fileTypes ~= textFileType;
    assert(!openFile.fileTypes.empty);
    assert(openFile.defaultFileType == textFileType);

    openFile.fileTypes = null;
    assert(openFile.fileTypes.empty);
    assert(openFile.defaultFileType == FileType.init);

    openFile.defaultFileType = textFileType;
    assert(!openFile.fileTypes.empty);
    assert(openFile.defaultFileType == textFileType);

    // note: cannot use as a test-case because the dialog is blocking,
    // we would have to send a key (like escape) asynchronously
    // in another thread to make the function return.
    //~ string result = openFile.show();
    //~ stderr.writeln(result);

    app.testRun();
}
