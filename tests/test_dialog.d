module test_dialog;

import core.thread;

import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk;
import dtk.tests.globals;

unittest
{
    auto app = new App;

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

    string result = openFile.show();
    stderr.writeln(result);

    app.run();
}

void main()
{
}
