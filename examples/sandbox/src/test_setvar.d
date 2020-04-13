module test_combobox;

import core.thread;

import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import std.string;

import dtk.interpreter;
import dtk.utils;

unittest
{
    string varName = "myvar";
    string[] values = [`foo " value`, `"bar value"`];
    tclEvalFmt("set %s [list %s]", varName, map!_tclEscape(values).join(" "));
    tclEvalFmt("puts $%s", varName);
}

void main()
{
}
