
#!/bin/bash

source ~/.functions/functions_drive.sh
source ~/.functions/functions_misc.sh
source ~/.functions/functions_steam.sh
source ~/.functions/functions_minecraft.sh

function main()
{
    DO_WHILE_LOOP="$1"

    #Remove Dead Screens
    screen -wipe  

    #Check for First Time Setup
    if [ ! -f "/opt/.initialized" ] 
    then 
        touch "/opt/.initialized"

        if [ ! -f "/opt/.drive_enabled" ] 
        then
            setupDrive
            echo "Finished Setup..."
        fi

        if [ "$STEAM_GAME" = "TRUE" ]
        then     
            if [ ! -f "/opt/.steam_username.sh" ] 
            then
                steam_DoInitialLogin
            fi
        fi

        exit 0
    fi

    if [ "$STEAM_GAME" = "TRUE" ]
    then 
        steam_DownloadMounts
    fi

    #Start SSH Server
    startSSH

    if [ "$SCREEN_NAME" = "garrys_mod" ]
    then
        source ~/.main/main_garrys_mod.sh
        main_garrys_mod "$DO_WHILE_LOOP"
    fi 

    if [ "$SCREEN_NAME" = "minecraft_vanilla" ]
    then
        source ~/.main/main_minecraft_vanilla.sh
        main_minecraft_vanilla "$DO_WHILE_LOOP"
    fi 

    if [ "$SCREEN_NAME" = "hl2dm" ]
    then
        source ~/.main/main_hl2dm.sh
        main_hl2dm "$DO_WHILE_LOOP"
    fi 
}

main "TRUE"