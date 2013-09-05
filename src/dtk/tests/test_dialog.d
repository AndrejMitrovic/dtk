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

    // ditto note as above
    //~ string result = saveFile.show();
    //~ stderr.writeln(result);

    auto colorSelect = new SelectColorDialog();
    colorSelect.initialColor = RGB(0, 0, 255);
    colorSelect.title = "Pick a color";

    // ditto note as above
    //~ auto res = colorSelect.show();
    //~ stderr.writefln("res: %s", res);

    auto msgBox = new MessageBox();
    msgBox.messageBoxType = MessageBoxType.ok;
    msgBox.title = "Hello!";
    msgBox.message = "Informative message.";
    msgBox.extraMessage = "Another informative message.";
    msgBox.defaultButtonType = MessageButtonType.ok;
    msgBox.messageBoxIcon = MessageBoxIcon.info;

    // ditto note as above
    //~ stderr.writeln(msgBox.show());

    app.testRun();
}
