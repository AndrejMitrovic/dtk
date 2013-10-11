module test_style;

import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk;

unittest
{
    auto app = new App;

    auto testWindow = new Window(app.mainWindow, 200, 200);
    testWindow.position = Point(500, 500);

    auto button = new Button(testWindow);
    assert(button.style == GenericStyle.button);

    auto checkButton = new CheckButton(testWindow);
    assert(checkButton.style == GenericStyle.checkButton);

    auto combobox = new Combobox(testWindow);
    assert(combobox.style == GenericStyle.combobox);

    auto entry = new Entry(testWindow);
    assert(entry.style == GenericStyle.entry);

    auto frame = new Frame(testWindow);
    assert(frame.style == GenericStyle.frame);

    auto label = new Label(testWindow);
    assert(label.style == GenericStyle.label);

    auto labelFrame = new LabelFrame(testWindow);
    assert(labelFrame.style == GenericStyle.labelFrame);

    auto notebook = new Notebook(testWindow);
    assert(notebook.style == GenericStyle.notebook);

    auto panedWindow = new PanedWindow(testWindow, Orientation.vertical);
    assert(panedWindow.style == GenericStyle.panedWindow);

    // todo: rename Orientation to Axis

    auto progressbar = new Progressbar(testWindow, Orientation.init, 100, ProgressMode.init);
    assert(progressbar.style == GenericStyle.progressbar);

    auto radioGroup = new RadioGroup(testWindow);
    auto radioButton= radioGroup.addButton("Set On", "on value");
    assert(radioButton.style == GenericStyle.radioButton);

    auto slider = new Slider(testWindow, Orientation.init, 100);
    assert(slider.style == GenericStyle.slider);

    // todo: verify ctor checks all widget arguments
    // todo: scrollbars should be more configurable since the xview/yview command
    // is possible to implement, and -xscrollcommand/-yscrollcommand for widgets.

    auto scrollbar = new Scrollbar(testWindow, entry, Orientation.init);
    assert(scrollbar.style == GenericStyle.scrollbar);

    auto separator = new Separator(testWindow, Orientation.init);
    assert(separator.style == GenericStyle.separator);

    // todo: sizegrip can't be constructed, but Window uses it,
    // but a sizegrip has configuration options we should check.
    // alternatively in the enableSizegrip function we should add
    // parameters for configuration
    //~ auto sizegrip = new Sizegrip(testWindow);
    //~ assert(sizegrip.style == GenericStyle.sizegrip);

    auto spinbox = new ScalarSpinbox(testWindow);
    assert(spinbox.style == GenericStyle.spinbox);

    auto text = new Text(testWindow);
    assert(text.style == GenericStyle.text);

    assert(testWindow.style == GenericStyle.window);

    auto tree = new Tree(testWindow);
    assert(tree.style == GenericStyle.tree);

    app.run();
}

void main()
{
}
