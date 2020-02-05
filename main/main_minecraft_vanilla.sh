#!/bin/bash

#Overload the Drive Server Start/Stop Functions

function server_stop()
{
    echo "Turning Saving Off..."
    sendCommandToScreen "$SCREEN_NAME" " "
    sendCommandToScreen "$SCREEN_NAME" "save-off"
    sendCommandToScreen "$SCREEN_NAME" "save-all"
}

function server_start()
{
    # resume autosaving on server

    cd "$SERVER_DIRECTORY/server"

    FRESH_START=$(isScreenRunning "$SCREEN_NAME")

    if [ "$FRESH_START" = "FALSE" ]
    then
        echo "Starting Server Back Up..."

        screen -DmS $SCREEN_NAME /usr/bin/java -server -Xms512M \
            -Xmx2048M -XX:+UseG1GC -XX:+CMSClassUnloadingEnabled \
            -XX:ParallelGCThreads=2 -XX:MinHeapFreeRatio=5 \
            -XX:MaxHeapFreeRatio=10 -jar minecraft_server.jar nogui & \

    else
        sendCommandToScreen "$SCREEN_NAME" "save-on"
    fi
}

function main_minecraft_vanilla()
{
    DO_WHILE_LOOP="$1"
    
    #Update Server
    #steam_UpdateServer "$SERVER_DIRECTORY/server" "4020" "anonymous"

    #Start Server
    server_start

    if [ "$DO_WHILE_LOOP" = "TRUE" ]
    then 
        while :
        do
            if [ $(date '+%H%M') = '0500' ]
            then 
                echo "Doing Drive Sync..."
                drive_sync_main
            fi

            echo "Sleeping for 30 Seconds..."
            sleep 30
        done
    fi
}