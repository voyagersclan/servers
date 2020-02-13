#!/bin/bash

function promptFunction()
{
    MESSAGE_TO_DISPLAY="$1"
    DEFAULT_VALUE="$2"
    TIMEOUT_VALUE="$3"

    VARIABLE_RESPONSE_TO_RETURN="FALSE"
    
    while true; do
        read -t $TIMEOUT_VALUE -p "$MESSAGE_TO_DISPLAY `echo $'\n> '`" -i "$DEFAULT_VALUE" yn || yn="$DEFAULT_VALUE"
        case $yn in
            [Yy]* ) VARIABLE_RESPONSE_TO_RETURN="TRUE"; break;;
            [Nn]* ) VARIABLE_RESPONSE_TO_RETURN="FALSE"; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done

    echo $VARIABLE_RESPONSE_TO_RETURN
}


function sendCommandToScreen()
{
    VARIABLE_SCREEN_NAME="$1"
    COMMAND="$2"
    COMMAND_EVAL="stuff \"$COMMAND\"\\015"
    screen -S ${VARIABLE_SCREEN_NAME} -X eval "$COMMAND_EVAL"
}

function syncWriteCacheToDisk()
{
    echo "Syncing Write Cache to Disk..."
    sync &
    wait $!
}

function misc_findReplace()
{
    VARIABLE_FIND="$1"
    VARIABLE_REPLACE="$2"
    VARIABLE_FILE="$3"

    sed -i "s/${VARIABLE_FIND}/${VARIABLE_REPLACE}/g" "$VARIABLE_FILE"
}

function waitForScreenTermination()
{
    VARIABLE_SCREEN_NAME="$1"

    while screen -list | grep -q $VARIABLE_SCREEN_NAME
    do
        sleep 1
    done
}

function isScreenRunning()
{
    VARIABLE_SCREEN_NAME="$1"

    if screen -list | grep -q $VARIABLE_SCREEN_NAME
    then
        echo "TRUE"
    else
        echo "FALSE"
    fi
}

function startSSH()
{
    FILE_CREDENTIALS="$HOME/.credentials.txt"

    if [ ! -f "$FILE_CREDENTIALS" ] 
    then
        VARIABLE_CURRENT_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
        VARIABLE_CURRENT_USER=$(whoami)
        VARIABLE_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
        echo -e "password\n$VARIABLE_PASSWORD\n$VARIABLE_PASSWORD" | passwd $VARIABLE_CURRENT_USER

        echo "$VARIABLE_CURRENT_IP" > $FILE_CREDENTIALS
        echo "$VARIABLE_CURRENT_USER" >> $FILE_CREDENTIALS
        echo "$VARIABLE_PASSWORD" >> $FILE_CREDENTIALS

        if [ -f "/opt/.drive_enabled" ] 
        then
            echo "Removing Old Credentials from Drive..."
            drive trash -quiet $FILE_CREDENTIALS
            echo "Pushing New Credentials to Drive..."
            drive push -no-prompt -quiet $FILE_CREDENTIALS
        fi

        truncate -s 0 $FILE_CREDENTIALS
    fi

    nohup /usr/sbin/sshd -D &
}