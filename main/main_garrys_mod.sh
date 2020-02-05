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
    main_process "FALSE"
}

function main_garrys_mod()
{
    DO_WHILE_LOOP="$1"
    
    #Update Server
    steam_UpdateServer "$SERVER_DIRECTORY/server" "4020" "anonymous"

    #Setup Mount Config
    steam_SetupMountConfig

    VARIABLE_EXTRA_ARGS="-game $STEAM_NAME_ID +map gm_construct +maxplayers 10  +gamemode \"terrortown\" +host_workshop_collection 284752217"

    #Start Server
    steam_StartServer "$VARIABLE_EXTRA_ARGS"

    if [ "$DO_WHILE_LOOP" = "TRUE" ]
    then 
        while :
        do
            if [ $(date '+%H%M') = '0500' ]
            then 
                echo "Doing Drive Sync..."
                drive_sync_main
            fi

            #echo "Sleeping for 30 Seconds..."
            sleep 30
        done
    fi
}