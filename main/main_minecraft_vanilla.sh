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

        VARIABLE_JAVA_ARGS="-server "
        VARIABLE_JAVA_ARGS+="-Xms512M -Xmx2048M "
        VARIABLE_JAVA_ARGS+="-XX:+UseG1GC "
        # VARIABLE_JAVA_ARGS+="-XX:+CMSClassUnloadingEnabled "
        VARIABLE_JAVA_ARGS+="-XX:ParallelGCThreads=2 "
        VARIABLE_JAVA_ARGS+="-XX:MinHeapFreeRatio=5 "
        VARIABLE_JAVA_ARGS+="-XX:MaxHeapFreeRatio=10 "
        VARIABLE_JAVA_ARGS+="-jar minecraft_server.jar nogui "
 
        screen -d -m -L -Logfile $SCREEN_LOG -S $SCREEN_NAME /usr/bin/java $VARIABLE_JAVA_ARGS & 

        #Kill all currently running Tail processes
        killall tail

        #Resume Log Tail process
        tail -n+1 -F $SCREEN_LOG &
    fi
}