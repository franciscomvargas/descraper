#!/bin/bash

# GET USER PATH
get_user=$(who)
USER=${get_user%% *}
USER_HOME="/home/$USER"


# -- Edit bellow vvvv DeSOTA DEVELOPER EXAMPLe: miniconda + pip pckgs + systemctl service

# SERVICE VARS
SERV_NAME=descraper.service



# -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I

# SUPER USER RIGHTS
[ "$UID" -eq 0 ] || { 
    echo "This script must be run as root."; 
    echo "  sudo $0";
    exit 1;
}

echo "Stoping Service..."
echo "    service name: $SERV_NAME"


systemctl stop $SERV_NAME

echo "    $SERV_NAME stopped"
exit
