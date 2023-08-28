#!/bin/sh
echo 40 | tee /sys/class/power_supply/BAT0/charge_control_start_threshold
echo 80 | tee /sys/class/power_supply/BAT0/charge_control_end_threshold
