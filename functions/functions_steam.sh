#!/bin/bash

declare -A MOUNT_KEYVALUE_LIST
MOUNT_KEYVALUE_LIST+=(["240"]="cstrike")
MOUNT_KEYVALUE_LIST+=(["440"]="tf") 
MOUNT_KEYVALUE_LIST+=(["280"]="hl1")
MOUNT_KEYVALUE_LIST+=(["360"]="hl1mp")
MOUNT_KEYVALUE_LIST+=(["220"]="hl2")
MOUNT_KEYVALUE_LIST+=(["320"]="hl2mp")
MOUNT_KEYVALUE_LIST+=(["340"]="lostcoast")
MOUNT_KEYVALUE_LIST+=(["380"]="episodic")
MOUNT_KEYVALUE_LIST+=(["420"]="ep2")
MOUNT_KEYVALUE_LIST+=(["500"]="left4dead")
MOUNT_KEYVALUE_LIST+=(["550"]="left4dead2")
MOUNT_KEYVALUE_LIST+=(["400"]="portal")
MOUNT_KEYVALUE_LIST+=(["620"]="portal2")

MOUNT_DIRECTORY="$SERVER_DIRECTORY/.mounts"

function steam_UpdateServer()
{
    DIRECTORY_FOR_UPDATE="$1"
    STEAM_APP_ID="$2"
    VARIABLE_STEAM_USERNAME="$3"

    STEAM_OUT="$DIRECTORY_FOR_UPDATE/steamcmd.out"

    mkdir -p "$DIRECTORY_FOR_UPDATE"
    cd "$DIRECTORY_FOR_UPDATE"

    EXIT_CODE=1
    
    MESSAGE_TO_DISPLAY="Updating and Validating App $STEAM_APP_ID in Directory $DIRECTORY_FOR_UPDATE"

    while [ $EXIT_CODE -ne 0 ]
    do
        echo "[Steam][RUNNING] $MESSAGE_TO_DISPLAY"

        /usr/games/steamcmd +login $VARIABLE_STEAM_USERNAME \
                            +force_install_dir "$DIRECTORY_FOR_UPDATE" \
                            +app_update "$STEAM_APP_ID" validate \
                            +quit > "$STEAM_OUT"

        EXIT_CODE=$?

        #echo "EXIT CODE IS $EXIT_CODE"
        
        if [ $EXIT_CODE -eq 8 ]; then
            cat "$STEAM_OUT"

            /usr/games/steamcmd +@sSteamCmdForcePlatformType windows \
                                +login $VARIABLE_STEAM_USERNAME \
                                +force_install_dir "$DIRECTORY_FOR_UPDATE" \
                                +app_update "$STEAM_APP_ID" validate \
                                +quit > "$STEAM_OUT"

            EXIT_CODE=$?

            #echo "EXIT CODE IS $EXIT_CODE"
        fi

        if [ $EXIT_CODE -ne 0 ]; then
            cat "$STEAM_OUT"

            echo "[Steam][FAILURE] $MESSAGE_TO_DISPLAY"
            sleep 60
        fi
    done
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo "[Steam][SUCCESS] $MESSAGE_TO_DISPLAY"
    fi 
}


function steam_DownloadMounts()
{
    VARIABLE_STEAM_USE_MOUNTS=$(promptFunction "[Steam] Does this game use Steam Mounts?")
    
    if [ "$VARIABLE_STEAM_USE_MOUNTS" = "TRUE" ]
    then
        touch "/opt/.steam_mounts_enabled"

        cd "$SERVER_DIRECTORY"
    
        STEAM_UPDATE_MOUNTS=$(promptFunction "[Steam] Update/Validate Mounts at this time?")

        if [ "$STEAM_UPDATE_MOUNTS" = "TRUE" ]
        then
            for MOUNT_ID in "${!MOUNT_KEYVALUE_LIST[@]}"
            do
                MOUNT_NAME=${MOUNT_KEYVALUE_LIST[$MOUNT_ID]}
                MOUNT_DESTINATION_DIRECTORY="$MOUNT_DIRECTORY/$MOUNT_NAME"

                steam_UpdateServer "$MOUNT_DESTINATION_DIRECTORY" "$MOUNT_ID" "$STEAM_USERNAME"
            done
        fi
    fi
}

function steam_SetupMountConfig()
{
    if [ -f "/opt/.steam_mounts_enabled" ] 
    then 
        cd $SERVER_DIRECTORY/server/$STEAM_NAME_ID/cfg

        echo '"mountcfg"' > mount.cfg
        echo '{' >> mount.cfg

        for MOUNT_ID in "${!MOUNT_KEYVALUE_LIST[@]}"
        do
            #Pull Values from Array
            MOUNT_NAME=${MOUNT_KEYVALUE_LIST[$MOUNT_ID]}
            MOUNT_DESTINATION_DIRECTORY="$MOUNT_DIRECTORY/$MOUNT_NAME/$MOUNT_NAME"

            echo "\"$MOUNT_NAME\" \"$MOUNT_DESTINATION_DIRECTORY\"" >> mount.cfg
        done
        
        echo '}' >> mount.cfg

        chmod 755 mount.cfg

        echo '"gamedepotsystem"' > mountdepots.txt
        echo '{' >> mountdepots.txt

        for MOUNT_ID in "${!MOUNT_KEYVALUE_LIST[@]}"
        do
            MOUNT_NAME=${MOUNT_KEYVALUE_LIST[$MOUNT_ID]}
            echo "\"$MOUNT_NAME\" \"1\"" >> mountdepots.txt
        done
        
        echo '}' >> mountdepots.txt

        chmod 755 mountdepots.txt
    fi
}

function steam_DoInitialLogin()
{
    cd "$SERVER_DIRECTORY"

    EXIT_CODE=1
    
    while [ $EXIT_CODE -ne 0 ]
    do
        read -p "Type Steam Username and Press Enter: " NEW_STEAM_USERNAME
        /usr/games/steamcmd +login $NEW_STEAM_USERNAME +quit

        EXIT_CODE=$?
    done

    echo "export STEAM_USERNAME=$NEW_STEAM_USERNAME" >  /opt/.steam_username.sh
    chmod 777 /opt/.steam_username.sh

    export STEAM_USERNAME="$NEW_STEAM_USERNAME"
}

function steam_StartServer()
{
    #Purposely not quoted for Arg Separation
    VARIABLE_EXTRA_ARGS="$1"
    
    cd $SERVER_DIRECTORY/server/

    #Remove Old Screen Log
    rm -f $SCREEN_LOG

    echo "Starting Steam with the Following Arguments $VARIABLE_EXTRA_ARGS"

    screen -L $SCREEN_LOG -DmS $SCREEN_NAME ./srcds_run \
                                            -console \
                                            $VARIABLE_EXTRA_ARGS & \
    
    #Kill all currently running Tail processes
    killall tail

    #Resume Log Tail process
    tail -n+1 -F $SCREEN_LOG &
}