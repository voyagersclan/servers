#!/bin/bash

#Overload the Drive Server Start/Stop Functions

function server_stop()
{
    sendCommandToScreen "$SCREEN_NAME" " "
    echo "Shutting Down Server..."
    sendCommandToScreen "$SCREEN_NAME" "quit"

    waitForScreenTermination "$SCREEN_NAME"
}

function server_start()
{
    echo "Starting Server Back Up..."

    STEAM_UPDATE_GAME=$(promptFunction "[Steam] Update Game at this Time?" "n" "10")

    if [ "$STEAM_UPDATE_GAME" = "TRUE" ]
    then
        #Update Server
        steam_UpdateServer "$SERVER_DIRECTORY/server" "232370" "anonymous"
    fi

    #Setup Mount Config
    steam_SetupMountConfig

    VARIABLE_EXTRA_ARGS="-game $STEAM_NAME_ID +map dm_lockdown +maxplayers 10"

    #Start Server
    steam_StartServer "$VARIABLE_EXTRA_ARGS"
}