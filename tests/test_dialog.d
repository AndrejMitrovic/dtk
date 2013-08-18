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

    /** Test open file dialog */
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


    //~ string result = openFile.show();
    //~ stderr.writeln(result);

    /** Test save file dialog */
    auto saveFile = new SaveFileDialog();

    assert(saveFile.fileTypes.empty);
    assert(saveFile.defaultFileType == FileType.init);

    saveFile.fileTypes ~= textFileType;
    assert(!saveFile.fileTypes.empty);
    assert(saveFile.defaultFileType == textFileType);

    saveFile.fileTypes = null;
    assert(saveFile.fileTypes.empty);
    assert(saveFile.defaultFileType == FileType.init);

    saveFile.defaultFileType = textFileType;
    assert(!saveFile.fileTypes.empty);
    assert(saveFile.defaultFileType == textFileType);

    saveFile.fileTypes ~= FileType("All files", "*");

    saveFile.defaultExtension = "myext";

    //~ string result = saveFile.show();
    //~ stderr.writeln(result);

    auto selectDir = new SelectDirDialog();
    selectDir.initialDir = r"C:\";
    selectDir.title = r"Select a directory for your project";

    //~ string result = selectDir.show();
    //~ stderr.writeln(result);

    auto colorSelect = new SelectColorDialog();
    colorSelect.initialColor = RGB(0, 0, 255);
    colorSelect.title = "Pick a color";

    auto res = colorSelect.show();
    stderr.writefln("res: %s", res);

    app.run();
}

void main()
{
}
