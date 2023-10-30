#!/bin/bash

# GET USER PATH
get_user=$(who)
USER=${get_user%% *}
USER_HOME="/home/$USER"


# -- Edit bellow vvvv DeSOTA DEVELOPER EXAMPLe: miniconda + pip pckgs + systemctl service

# SERVICE VARS
SERV_NAME=descraper.service



# -- Edit bellow if you're felling lucky ;) -- https://youtu.be/5NV6Rdv1a3I

systemctl is-active --quiet $SERV_NAME
_serv_status=$?
STDOUT=""
# retrieved from https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#Exit%20status
if [ "$_serv_status" -eq "0" ];
then
    echo "SERVICE_RUNNING"
    exit
fi
if [ "$_serv_status" -eq "1" ];
then
    echo "SERVICE_STOPPED"
    exit
fi
if [ "$_serv_status" -eq "3" ];
then
    echo "SERVICE_INACTIVE"
    exit
fi
echo "SERVICE_STATUS_UNKNOWN"
exit