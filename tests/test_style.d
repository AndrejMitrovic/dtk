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

    assert(testWindow.style == DefaultStyle.window);

    auto button = new Button(testWindow);
    assert(button.style == DefaultStyle.button);

    auto checkButton = new CheckButton(testWindow);
    assert(checkButton.style == DefaultStyle.checkButton);

    auto combobox = new Combobox(testWindow);
    assert(combobox.style == DefaultStyle.combobox);

    auto entry = new Entry(testWindow);
    assert(entry.style == DefaultStyle.entry);

    auto frame = new Frame(testWindow);
    assert(frame.style == DefaultStyle.frame);

    auto label = new Label(testWindow);
    assert(label.style == DefaultStyle.label);

    auto labelFrame = new LabelFrame(testWindow);
    assert(labelFrame.style == DefaultStyle.labelFrame);

    auto notebook = new Notebook(testWindow);
    assert(notebook.style == DefaultStyle.notebook);

    auto panedWindow = new PanedWindow(testWindow, Angle.vertical);
    assert(panedWindow.style == DefaultStyle.panedWindow);

    auto vProg = new Progressbar(testWindow, ProgressMode.init, Angle.vertical, 100);
    assert(vProg.style == DefaultStyle.vProgressbar);

    auto hProg = new Progressbar(testWindow, ProgressMode.init, Angle.horizontal, 100);
    assert(hProg.style == DefaultStyle.hProgressbar);

    auto text = new Text(testWindow);
    assert(text.style == DefaultStyle.text);

    auto vScroll = new Scrollbar(testWindow, text, Angle.vertical);
    assert(vScroll.style == DefaultStyle.vScrollbar);

    auto hScroll = new Scrollbar(testWindow, text, Angle.horizontal);
    assert(hScroll.style == DefaultStyle.hScrollbar);

    auto vSlider = new Slider(testWindow, Angle.vertical, 100);
    assert(vSlider.style == DefaultStyle.vSlider, vSlider.style.text);

    auto hSlider = new Slider(testWindow, Angle.horizontal, 100);
    assert(hSlider.style == DefaultStyle.hSlider);

    auto radioGroup = new RadioGroup(testWindow);
    auto radioButton= radioGroup.addButton("Set On", "on value");
    assert(radioButton.style == DefaultStyle.radioButton);

    auto separator = new Separator(testWindow, Angle.init);
    assert(separator.style == DefaultStyle.separator);

    auto spinbox = new ScalarSpinbox(testWindow);
    assert(spinbox.style == DefaultStyle.spinbox);

    auto tree = new Tree(testWindow);
    assert(tree.style == DefaultStyle.tree);

    app.run();
}

void main()
{
}
