module dtk.tests.test_window;

version(unittest):
version(DTK_UNITTEST):

import std.algorithm;
import std.range;
import std.traits;

import dtk;
import dtk.tests.globals;

/**
    Philippe Sigaud's Permutations from dranges.
    See https://github.com/PhilippeSigaud/dranges
    and http://www.dsource.org/projects/dranges.
*/
struct Permutations(R)
{
    ElementType!R[] _input, _perm;
    size_t k, n;

    this(R r)
    {
        _input = array(r);
        _perm = array(r);
        n = _perm.length;
        k = n;
    }

    this(R r, size_t elems)
    {
        _input = array(r);
        _perm = array(r);
        n = min(elems, _perm.length);
        k = n;
    }

    ElementType!R[] front() { return _perm;}

    bool empty() { return (n == 1 && k == 0 )|| (n > 1 && k <= 1); }

    @property Permutations save() { return this; }

    void popFront()
    {
        k = n;
        if (k == 0)
        {
            n = 1; // permutation of an empty range or of zero elements
        }
        else
        {
            C3: _perm = _perm[1 .. k] ~ _perm[0] ~ _perm[k .. $];
            if (_perm[k - 1] == _input[k - 1])
            {
                k--;
                if (k > 1) goto C3;
            }
        }
    }
}

/// ditto
Permutations!R permutations(R)(R r) if (isDynamicArray!R)
{
    return Permutations!R(r);
}

/// ditto
Permutations!R permutations(R)(R r, size_t n) if (isDynamicArray!R)
{
    return Permutations!R(r, n);
}

/// ditto
Permutations!(ElementType!R[]) permutations(R)(R r)
    if (!isDynamicArray!R && isForwardRange!R && !isInfinite!R)
{
    return Permutations!(ElementType!R[])(array(r));
}

/// ditto
Permutations!(ElementType!R[]) permutations(R)(R r, size_t n)
    if (!isDynamicArray!R && isForwardRange!R && !isInfinite!R)
{
    return Permutations!(ElementType!R[])(array(r), n);
}

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);

    testWindow.title = "test window";
    assert(testWindow.title == "test window");

    testWindow.position = Point(200, 200);
    assert(testWindow.position == Point(200, 200));

    testWindow.position = Point(-200, -200);
    assert(testWindow.position == Point(-200, -200));

    testWindow.size = Size(300, 400);
    assert(testWindow.size == Size(300, 400));

    testWindow.geometry = Rect(-100, 100, 250, 250);
    assert(testWindow.position == Point(-100, 100));
    assert(testWindow.size == Size(250, 250));
    assert(testWindow.geometry == Rect(-100, 100, 250, 250));

    testWindow.geometry = Rect(100, 100, 250, 250);
    assert(testWindow.position == Point(100, 100));
    assert(testWindow.size == Size(250, 250));
    assert(testWindow.geometry == Rect(100, 100, 250, 250));

    // @bug: http://stackoverflow.com/questions/18043720/odd-results-for-wm-geometry

    assert(testWindow.parentWindow is app.mainWindow);

    auto childWin = new Window(testWindow, 200, 200);
    childWin.position = Point(250, 250);
    childWin.title = "child window 1";
    assert(testWindow.parentWindow is app.mainWindow);
    assert(childWin.parentWindow is testWindow);

    childWin.setAlpha(0.5);
    assert(childWin.getAlpha() < 0.6);
    childWin.setAlpha(1.0);

    childWin.maximizeWindow();
    childWin.unmaximizeWindow();

    auto button1 = new Button(testWindow, "FooButton");
    auto button2 = new Button(testWindow, "BarButton");

    auto children = testWindow.childWidgets;
    assert(children.front is childWin);
    children.popFront();
    assert(children.front is button1);
    children.popFront();
    assert(children.front is button2);

    testWindow.setTopWindow();
    assert(testWindow.isAbove(childWin));
    assert(childWin.isBelow(testWindow));

    childWin.setTopWindow();
    assert(childWin.isAbove(testWindow));
    assert(testWindow.isBelow(childWin));

    auto childWin2 = new Window(testWindow, 200, 200);
    childWin2.position = Point(300, 300);
    childWin2.title = "child window 2";

    testWindow.setTopWindow();
    childWin.setTopWindow();
    childWin2.setTopWindow();

    assert(childWin2.isAbove(childWin));
    assert(childWin2.isAbove(testWindow));
    assert(childWin.isAbove(testWindow));

    testWindow.setBottomWindow();
    childWin.setBottomWindow();
    childWin2.setBottomWindow();

    assert(testWindow.isAbove(childWin));
    assert(testWindow.isAbove(childWin2));
    assert(childWin.isAbove(childWin2));

    childWin2.setBottomWindow();
    childWin.setBottomWindow();
    testWindow.setBottomWindow();

    assert(childWin2.isAbove(childWin));
    assert(childWin2.isAbove(testWindow));
    assert(childWin.isAbove(testWindow));

    foreach (Window[3] win; [childWin, childWin2, testWindow].permutations)
    {
        win[0].setAbove(win[1]);
        assert(win[0].isAbove(win[1]));

        win[1].setAbove(win[2]);
        assert(win[1].isAbove(win[2]));

        win[2].setAbove(win[1]);
        assert(win[2].isAbove(win[1]));

        win[2].setAbove(win[0]);
        assert(win[2].isAbove(win[0]));

        win[0].setBelow(win[1]);
        assert(win[0].isBelow(win[1]));

        win[1].setBelow(win[2]);
        assert(win[1].isBelow(win[2]));

        win[2].setBelow(win[1]);
        assert(win[2].isBelow(win[1]));

        win[2].setBelow(win[0]);
        assert(win[2].isBelow(win[0]));
    }

    testWindow.minimizeWindow();
    assert(testWindow.isMinimized);

    testWindow.unminimizeWindow();
    assert(!testWindow.isMinimized);

    testWindow.setResizable(CanResizeWidth.no, CanResizeHeight.no);

    // can still be resized through the API
    testWindow.size = Size(250, 250);
    assert(testWindow.size == Size(250, 250));

    app.testRun();
}
