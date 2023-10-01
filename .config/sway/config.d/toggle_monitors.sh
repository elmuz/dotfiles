#!/bin/bash
# This script turns off all the outputs apart from those passed as arguments
#
# Example:
# $ ./toggle_monitors.sh eDP-1

readarray -t OUTPUTS <  <(swaymsg -t get_outputs | jq -r '.[].name')
for o in "${OUTPUTS[@]}"
do
  swaymsg output $o disable
  swaymsg output $o power off
done

# Wait 1 seconds to avoid quick turn off/on
sleep 1

for arg in "$@"
do
  swaymsg output $arg power on
  swaymsg output $arg enable
done
