#!/bin/sh
 cat << EOF
#######################################################################################
############################# Backup snapshots guidelines #############################
#######################################################################################
# 1) install rsnapshot                                                                #
# 2) copy configuration file from .config/rsnapshot/rsnapshot.conf to                 #
#    /etc/rsnapshot.conf                                                              #
# 3) mount external hard drive to /mnt                                                #
# 4) create a 'backups' root folder (e.g. 'snapshot_root = /mnt/backups')             #
# 5) run 'sudo rsnapshot -V daily'                                                    #
#######################################################################################
EOF
