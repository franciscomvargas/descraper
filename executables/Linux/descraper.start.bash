#!/bin/bash

# GET USER PATH
get_user=$(who)
USER=${get_user%% *}
USER_HOME="/home/$USER"


# -- Edit bellow vvvv DeSOTA DEVELOPER EXAMPLe: miniconda + pip pckgs + systemctl service

# SERVICE VARS
SERV_NAME=descraper.service
SERV_PORT=8880
SERV_WAITER="curl localhost:$SERV_PORT/api/handshake"
SHAKE_RES="{\"status\":\"ready\"}"



# -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I

# SUPER USER RIGHTS
[ "$UID" -eq 0 ] || { 
    echo "This script must be run as root."; 
    echo "  sudo $0";
    exit 1;
}

echo "Starting Service..."
echo "    service name: $SERV_NAME"

systemctl start $SERV_NAME

if test "$SERV_WAITER" = ""
then
    echo "    $SERV_NAME started"
    exit
fi

_curr_stat=$($SERV_WAITER 2>/dev/nul)
_char_stat=1
sp="/-\|"
echo
echo -n "Wainting for asset handshake  ";
while [ "$_curr_stat" != "$SHAKE_RES" ];
do
    printf "\b${sp:_char_stat++%${#sp}:1}"
    _curr_stat=$($SERV_WAITER 2>/dev/nul)
done
echo
echo "    $SERV_NAME started"
exit