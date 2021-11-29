
#!/bin/bash

source ~/.functions/functions_drive.sh
source ~/.functions/functions_misc.sh
source ~/.functions/functions_steam.sh
source ~/.functions/functions_minecraft.sh

function main()
{
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

    #Start Remote Management
    startRemoteManagement

    if [ "$SCREEN_NAME" = "garrys_mod" ]
    then
        source ~/.main/main_garrys_mod.sh
    fi 

    if [ "$SCREEN_NAME" = "minecraft_vanilla" ]
    then
        source ~/.main/main_minecraft_vanilla.sh
    fi 

    if [ "$SCREEN_NAME" = "hl2dm" ]
    then
        source ~/.main/main_hl2dm.sh
    fi 

    if [ "$SCREEN_NAME" = "discord_server_bot" ]
    then
        source ~/.main/main_discord_server_bot.sh
    fi 


    VARIABLE_GOOGLE_DRIVE_DO_BACKUP=$(promptFunction "[Google Drive] Backup to Google Drive?" "y" "10")

    if [ "$VARIABLE_GOOGLE_DRIVE_DO_BACKUP" = "TRUE" ]
    then
        drive_sync_main
    else
        server_start
    fi

    while :
    do
        if [ $(date '+%H%M') = '0600' ]
        then 
            echo "Doing Drive Sync..."
            drive_sync_main
        fi

        sleep 30
    done
}

main