#!/bin/bash
 
lock=" Lock"
logout=" Logout"
shutdown=" Shutdown"
reboot=" Reboot"
sleep=" Suspend"
 
selected_option=$(echo "$lock
$logout
$sleep
$reboot
$shutdown" | fuzzel --dmenu -w 8 -l 5 -x 80 --text-color eceff4aa)

if [ "$selected_option" == "$lock" ]
then
    swaylock -f
elif [ "$selected_option" == "$logout" ]
then
    loginctl terminate-user `whoami`
elif [ "$selected_option" == "$shutdown" ]
then
    loginctl poweroff
elif [ "$selected_option" == "$reboot" ]
then
    loginctl reboot
elif [ "$selected_option" == "$sleep" ]
then
    systemctl suspend
else
    echo "Invalid choice"
fi
