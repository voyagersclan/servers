
#!/bin/bash

source ~/.functions/functions_drive.sh
source ~/.functions/functions_misc.sh
source ~/.functions/functions_steam.sh

#Do Not Modify, any changes that are needed to be made should be 
#done under build.sh these are not to be changed

#Begin - Mandatory Parameters
GOOGLE_DRIVE_ENABLED="TRUE"
#Begin - Mandatory Parameters

#Begin - Optional Steam Specific
STEAM_USE_MOUNTS="TRUE"
STEAM_USERNAME="anonymous"
#End - Optional Steam Specific

function main()
{
    DO_WHILE_LOOP="$1"

    #echo "Sleeping for 45 seconds in case of user updates..."
    #sleep 30 

    #Check for First Time Setup
    if [ ! -d "/opt/.gd" ] 
    then
        setupDrive

        if [ "$STEAM_GAME" = "TRUE" ]
        then 
            steam_DoInitialLogin
            steam_DownloadMounts
        fi

        echo "Finished Setup..."
    else
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
    fi
}

main "TRUE"