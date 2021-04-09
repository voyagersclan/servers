#!/bin/bash

#Overload the Drive Server Start/Stop Functions

function server_stop()
{
    echo "Stopping Server..."
    pkill -f node
    waitForScreenTermination "$SCREEN_NAME"
}

function server_start()
{
    cd "$SERVER_DIRECTORY/server"

    #Check for First Time Setup
    if [ ! -f "/opt/.discord_server_bot_initialized" ] 
    then 
        touch "/opt/.discord_server_bot_initialized"

        CONFIGURE_AWS=$(promptFunction "[AWS] Configure AWS at this time?" "n" "900")

        if [ "$CONFIGURE_AWS" = "TRUE" ]
        then
            aws configure
        fi

        CLONE_DISCORD_BOT=$(promptFunction "[GIT] Clone Bot at this time?" "n" "900")

        if [ "$CONFIGURE_AWS" = "TRUE" ]
        then
            git clone "https://github.com/qwertycody/AWS-Discord-Bot.git" "$SERVER_DIRECTORY/server/AWS-Discord-Bot"
        fi
    fi

    FRESH_START=$(isScreenRunning "$SCREEN_NAME")

    if [ "$FRESH_START" = "FALSE" ]
    then
        echo "Starting Server..."

        #Remove Old Screen Log
        rm -f $SCREEN_LOG

        cd "$SERVER_DIRECTORY/server/AWS-Discord-Bot/DiscordBot"

        screen -L $SCREEN_LOG -DmS $SCREEN_NAME node src/Bot.js & \

        #Kill all currently running Tail processes
        killall tail

        #Resume Log Tail process
        tail -n+1 -F $SCREEN_LOG &
    fi
}