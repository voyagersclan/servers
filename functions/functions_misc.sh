#!/bin/bash

function promptFunction()
{
    MESSAGE_TO_DISPLAY="$1"

    VARIABLE_RESPONSE_TO_RETURN="FALSE"
    
    while true; do
        read -p "$MESSAGE_TO_DISPLAY" yn
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