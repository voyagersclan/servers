#!/bin/bash

#Overload the Drive Server Start/Stop Functions

function server_stop()
{
    echo "Stopping Server..."
    sendCommandToScreen "$SCREEN_NAME" " "
    sendCommandToScreen "$SCREEN_NAME" "stop"
    waitForScreenTermination "$SCREEN_NAME"
}

function server_start()
{
    cd "$SERVER_DIRECTORY/server"

    FRESH_START=$(isScreenRunning "$SCREEN_NAME")

    if [ "$FRESH_START" = "FALSE" ]
    then
        echo "Updating Server..."
        getLatestServerJar "$SERVER_DIRECTORY/server/minecraft_server.jar"

        echo "Starting Server..."

        #Remove Old Screen Log
        rm -f $SCREEN_LOG

        screen -L $SCREEN_LOG -DmS $SCREEN_NAME /usr/bin/java -server -Xms512M \
            -Xmx2048M -XX:+UseG1GC -XX:+CMSClassUnloadingEnabled \
            -XX:ParallelGCThreads=2 -XX:MinHeapFreeRatio=5 \
            -XX:MaxHeapFreeRatio=10 -jar minecraft_server.jar nogui & \

        #Kill all currently running Tail processes
        killall tail

        #Resume Log Tail process
        tail -n+1 -F $SCREEN_LOG &
    fi
}

function main_minecraft_vanilla()
{
    DO_WHILE_LOOP="$1"
    
    #Update Server
    #todo

    #Start Server
    server_start

    if [ "$DO_WHILE_LOOP" = "TRUE" ]
    then 
        while :
        do
            if [ $(date '+%H%M') = '0700' ]
            then 
                echo "Doing Drive Sync..."
                drive_sync_main
            fi

            sleep 30
        done
    fi
}