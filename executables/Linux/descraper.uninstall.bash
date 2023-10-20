#!/bin/bash

# GET USER PATH
get_user=$(who)
USER=${get_user%% *}
USER_HOME="/home/$USER"
# Setup VARS
MODEL_NAME=DeScraper
MODEL_SERVICE=descraper.service
# - Model Path
MODEL_PATH=$USER_HOME/Desota/Desota_Models/$MODEL_NAME

# SUPER USER RIGHTS
[ "$UID" -eq 0 ] || { 
    echo "This script must be run as root to delete a systemctl service!"; 
    echo "Usage:"; 
    echo "sudo $0 [-q] [-h]";
    echo "    -q = Hands Free (quiet)";
    echo "    -h = Help";
    echo "    [] = Optional";
    exit 1;
}

# IPUT ARGS: -q="Quiet uninstall"; -p="User Password"
quiet=0
while getopts qhe: flag
do
    case $flag in
        q)  quiet=1;;
        h)  { 
            echo "Usage:"; 
            echo "sudo $0 [-q] [-h]";
            echo "    -q = Hands Free (quiet)";
            echo "    -h = Help";
            echo "    [] = Optional";
            exit 1;
        };;
        ?)  { 
            echo "Usage:"; 
            echo "sudo $0 [-q] [-h]";
            echo "    -q = Hands Free (quiet)";
            echo "    -h = Help";
            echo "    [] = Optional";
            exit 1;
        };;
    esac
done

# Copy File from future  deleted folder
SCRIPTPATH=$(realpath -s "$0")
BASENAME=$(basename $SCRIPTPATH)
if test "$SCRIPTPATH" = "$USER_HOME/$BASENAME"
then
    echo "Input Arguments:"
    echo "    quiet [-q]: $quiet"
else
    if ( test -e "$USER_HOME/$BASENAME" ); then
        rm $USER_HOME/$BASENAME
    fi
    cp $SCRIPTPATH $USER_HOME/$BASENAME
    #chown -R $USER $USER_HOME/$BASENAME
    if [ "$quiet" -eq "0" ]; 
    then
        /bin/bash $USER_HOME/$BASENAME
    else
        /bin/bash $USER_HOME/$BASENAME -q
    fi
    exit
fi

# STOP SERVICE
systemctl stop $MODEL_SERVICE
systemctl disable $MODEL_SERVICE
if [ "$quiet" -eq "0" ]; 
    then
    # DELETE SERVICE
    rm -r /lib/systemd/system/$MODEL_SERVICE
    rm -r /etc/systemd/system/$MODEL_SERVICE&> /dev/null # and symlinks that might be related
    rm -r /usr/lib/systemd/system/$MODEL_SERVICE&> /dev/null 
    rm -r /usr/lib/systemd/system/$MODEL_SERVICE&> /dev/null # and symlinks that might be related
    systemctl daemon-reload
    systemctl reset-failed

    # DELETE PROJECT
    rm -r $MODEL_PATH
else
    # DELETE SERVICE
    rm -rf /lib/systemd/system/$MODEL_SERVICE&> /dev/null
    rm -rf /etc/systemd/system/$MODEL_SERVICE&> /dev/null
    rm -rf /etc/systemd/system/$MODEL_SERVICE&> /dev/null # and symlinks that might be related
    rm -rf /usr/lib/systemd/system/$MODEL_SERVICE&> /dev/null 
    rm -rf /usr/lib/systemd/system/$MODEL_SERVICE&> /dev/null # and symlinks that might be related
    systemctl daemon-reload&> /dev/null
    systemctl reset-failed&> /dev/null

    # DELETE PROJECT
    rm -rf $MODEL_PATH
fi

if ( test -d "$MODEL_PATH" ); then
    echo 'Uninstall Fail'
    echo ">DEV TIP< Delete this folder:"
    echo "    $MODEL_PATH"
else
    echo 'Uninstalation Completed!'
fi

rm -rf $USER_HOME/$BASENAME
exit