#!/bin/bash

# GET USER PATH
get_user=$(who)
USER=${get_user%% *}
USER_HOME="/home/$USER"
# Setup VARS
MODEL_NAME=DeScraper
# - Model Release
MODEL_RELEASE=https://github.com/franciscomvargas/deurlcruncher/archive/refs/tags/v0.0.0.zip
# - Model Path
#   $PWD = \home\[username]\Desota\Desota_Models\DeUrlCruncher\executables\Linux
MODEL_PATH=$USER_HOME/Desota/Desota_Models/$MODEL_NAME
# - Create Service Script
EXECS_PATH=$MODEL_PATH/executables/Linux
CREATE_SERV=$EXECS_PATH/create_service.py
SERV_NAME=descraper.service
SERV_PORT=8880
SERV_PATH=$EXECS_PATH/$SERV_NAME

# SUPER USER RIGHTS
[ "$UID" -eq 0 ] || { 
    echo "This script must be run as root to create a systemctl service!"; 
    echo "Usage:"; 
    echo "sudo $0 [-s] [-d] [-h]";
    echo "    -s = Start Service";
    echo "    -d = Echo everything (debug)";
    echo "    -h = Help";
    echo "    [] = Optional";
    exit 1;
}

# Program Installers
#   - Miniconda
architecture=$(uname -m)
case $architecture in
        x86_64) miniconda_dwnld=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh;;
        x86) miniconda_dwnld=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86.sh;;
        aarch64) miniconda_dwnld=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh;;
        arm) miniconda_dwnld=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-armv7l.sh;;
        s390x) miniconda_dwnld=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-s390x.sh;;
        ppc64le) miniconda_dwnld=https://repo.aanaconda.com/miniconda/Miniconda3-latest-Linux-ppc64le.sh;;
        ?) miniconda_dwnld=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh;;
esac
# IPUT ARGS - -s="Start Model Service"; -d="Print stuff and Pause at end"
startmodel=0
debug=0
while getopts sdhe: flag
do
    case $flag in
        s) startmodel=1;;
        d) debug=1;;
        h) { 
            echo "Usage:"; 
            echo "sudo $0 [-s] [-d] [-h]";
            echo "    -s = Start Service";
            echo "    -d = Echo everything (debug)";
            echo "    -h = Help";
            echo "    [] = Optional";
            exit 1;
        };;
        ?) {
            echo "Usage:"; 
            echo "sudo $0 [-s] [-d] [-h]";
            echo "    -s = Start Service";
            echo "    -d = Echo everything (debug)";
            echo "    -h = Help";
            echo "    [] = Optional";
            exit 1;
        };;
    esac
done
echo "Input Arguments:"
echo "    startmodel [-s]: $startmodel"
echo "    debug [-d]: $debug"

# Move to Project Folder
if ( test -d "$MODEL_PATH" ); 
then
    cd $MODEL_PATH
    echo
    echo "Step 1/3 - Move (cd) to Project Path:"
    echo "    $PWD"
else
    echo "Error:"
    echo "# Description: Model not installed correctly"
    echo "    expected_path = $MODEL_PATH"
    echo "DEV TIP:"
    echo "# Download Release with this command:"
    echo "    TODO\n"
    exit
fi

# Install Conda IF Required
echo


echo "Step 2/3 - Install Miniconda for Project"
# Install Conda if Required - https://developers.google.com/earth-engine/guides/python_install-conda#linux
# Miniconda Instalation Status
CONDA_BASE=$USER_HOME/Desota/Portables/miniconda3
. $CONDA_BASE/etc/profile.d/conda.sh
conda --version > /dev/null
condastatus=$?
if [ "$condastatus" -eq "0" ];
then
    echo "    Miniconda Installed"
else
    echo "    Miniconda Instalation Started..."
    # Download the Miniconda installer to your Home directory.
    echo "Miniconda Download URL:"
    echo "    $miniconda_dwnld"
    wget $miniconda_dwnld -O $USER_HOME/miniconda.sh
    chown -R $USER $USER_HOME/miniconda.sh
    # Install Miniconda quietly, accepting defaults, to your Home directory.
    bash $USER_HOME/miniconda.sh -b -u -p $USER_HOME/Desota/Portables/miniconda3 > /dev/null
    chown -R $USER $USER_HOME/Desota/Portables
    chown -R $USER $USER_HOME/Desota/Portables/miniconda3
    # Remove the Miniconda installer from your Home directory.
    rm -rf $USER_HOME/miniconda.sh
    # Add Miniconda to PATH variable
    chmod 666 $USER_HOME/.bashrc
    _exoport_PATH=$USER_HOME/Desota/Portables/miniconda3/bin
    printf '\n# >>> conda initialize >>>\n'>> $USER_HOME/.bashrc
    printf '# !! Contents within this block are managed by "desota setup" !!\n'>> $USER_HOME/.bashrc
    printf '__conda_setup="$('>> $USER_HOME/.bashrc
    printf "'%s/Desota/Portables/miniconda3/bin/conda' " $USER_HOME>> $USER_HOME/.bashrc
    printf "'shell.bash' 'hook' 2> /dev/null)">> $USER_HOME/.bashrc
    printf '"\n'>> $USER_HOME/.bashrc
    printf 'if [ $? -eq 0 ]; then\n'>> $USER_HOME/.bashrc
    printf '    eval "$__conda_setup"\n' >> $USER_HOME/.bashrc
    printf 'else\n'>> $USER_HOME/.bashrc
    printf '    if [ -f "%s/etc/profile.d/conda.sh" ]; then\n' $CONDA_BASE>> $USER_HOME/.bashrc
    printf '        . "%s/etc/profile.d/conda.sh"\n' $CONDA_BASE>> $USER_HOME/.bashrc
    printf '    else\n'>> $USER_HOME/.bashrc
    printf '        %s\n' $_exoport_PATH>> $USER_HOME/.bashrc
    printf '    fi\n'>> $USER_HOME/.bashrc
    printf 'fi\n'>> $USER_HOME/.bashrc
    printf 'unset __conda_setup\n'>> $USER_HOME/.bashrc
    printf '# <<< conda initialize <<<\n'>> $USER_HOME/.bashrc
    eval_cmd=$(cat $USER_HOME/.bashrc | tail -n +16)
    eval "$eval_cmd"

    # Dont start shell in (base)
    conda config --set auto_activate_base false
fi


# Create/Activate Conda Virtual Environment
echo "Creating MiniConda Environment..."
if [ "$debug" -eq "1" ]; 
then
    conda create --prefix $MODEL_PATH/env -y
    conda activate $MODEL_PATH/env
else
    conda create --prefix $MODEL_PATH/env -y&> /dev/null
    conda activate $MODEL_PATH/env&> /dev/null
fi
echo $CONDA_PREFIX


# Install required Libraries
echo
echo "Step 3/3 - Install Project Packages"
if [ "$debug" -eq "1" ]; 
then
    conda install pip -y
    pip install -r $MODEL_PATH/requirements.txt
fi
if [ "$debug" -ne "1" ]; 
then
    conda install pip -y &> /dev/null
    pip install -r $MODEL_PATH/requirements.txt &> /dev/null
    echo
    echo 'Packages Installed:'
    pip freeze
fi

# Deactivate CONDA
conda deactivate
chown -R $USER $MODEL_PATH/env

# Create Service
echo
echo "Step 4/4 - Create Systemctl Service"
# Create User Service Files
$MODEL_PATH/env/bin/python3 $CREATE_SERV --user_home $USER_HOME
# Append Service to systemctl
cp $SERV_PATH /lib/systemd/system
systemctl daemon-reload

# Start Model ?
if [ "$startmodel" -eq "1" ]; 
then
    echo "Starting Service..."
    systemctl start $SERV_NAME
    echo "    Open Model: http://127.0.0.1:$SERV_PORT"
fi

echo
echo 'Setup Completed!'
exit
    
