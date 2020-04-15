#!/bin/sh
dub build --arch=x86_64

# Headless xserver, otherwise Tkiner would fail to initialize
# See: http://elementalselenium.com/tips/38-headless
xvfb-run dub test --arch=x86_64
