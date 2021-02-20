#!/bin/sh

# `modesetting` and `intel` driver give different names to monitors

if [[ $(grep intel /usr/share/X11/xorg.conf.d/20-intel.conf) =~ "#" ]]; then
	s="-"
else
	s=""
fi

eDP1="eDP${s}1"
DP1="DP${s}1"
DP2="DP${s}2"
DP3="DP${s}3"
DP4="DP${s}4"
HDMI1="HDMI${s}1"

if xrandr | grep "$DP2 connected"; then
    xrandr --output $eDP1 --mode 1368x768 --pos 3000x732 --rotate normal --rate 59.94 \
	    --output $DP1 --mode 1920x1080 --pos 0x0 --rotate right --rate 59.94 \
	    --output $DP2 --primary --mode 1920x1080 --pos 1080x410 --rotate normal --rate 59.94 \
	    --output $DP3 --off \
	    --output $DP4 --off \
	    --output $HDMI1 --off
else
    xrandr --output $eDP1 --mode 1600x900 --rotate normal
fi
