#!/bin/sh
dub build --arch=x86_64

# Headless xserver, otherwise Tkiner would fail to initialize
# See: http://elementalselenium.com/tips/38-headless
# Note: unlike on Linux, the 'xvfb-run' script is not available here
# Xvfb :99 &
# export DISPLAY=:99

export PATH="/usr/local/opt/tcl-tk/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/tcl-tk/lib"

export DISPLAY=:0
dub test --arch=x86_64
