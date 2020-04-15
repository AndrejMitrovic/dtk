#!/bin/sh
dub build --arch=x86_64

# Many thanks to this article:
# https://www.richud.com/wiki/Ubuntu_Fluxbox_GUI_with_x11vnc_and_Xvfb

# We need to remove all window decoration in fluxbox because otherwise when we
# set the window position it's always offsetted by the decoration.
# Note: do not use deco BORDER because that will add a 1 pixel offset
cat <<EOT > ~/.fluxbox/apps
[app] (.*)
        [Deco]  {NONE}
[end]
EOT

# Keyboard test requires an active WM
export dskip=dtk.tests.events_keyboard
xvfb-run dub test --arch=x86_64

# Then run it with a WM to test keyboard handling events (requires a WM)
export dskip=dtk.tests.events_geometry,dtk.tests.window
export DISPLAY=:1
Xvfb :1 -screen 0 1024x768x24 &
sleep 1s
nohup fluxbox & > /dev/null
sleep 1s
nohup x11vnc -display :1 -bg -nopw -xkb > /dev/null
sleep 1s
# Now test
dub test --arch=x86_64
