#!/bin/bash

function setupDrive()
{
    VARIABLE_GOOGLE_DRIVE_ENABLED=$(promptFunction "[Google Drive] Enable Sync Functionality?" "y" "10")
    
    if [ "$VARIABLE_GOOGLE_DRIVE_ENABLED" = "TRUE" ]
    then
        touch /opt/.drive_enabled

        if [ ! -d "/opt/.gd" ]         
        then
            echo "[Google Drive] Initializing Drive Functionality..."
            drive init /opt
        fi 

        echo "[Google Drive] Establishing Initial Directories..."
        mkdir -p "$SERVER_DIRECTORY"
        mkdir -p "$SERVER_DIRECTORY/backup"

        echo "[Google Drive] Pushing Initial Directory for $SERVER_DIRECTORY..."
        #drive push -no-prompt -quiet -directories "$SERVER_DIRECTORY"
        drive push -no-prompt -directories "$SERVER_DIRECTORY"

        echo "[Google Drive] Pushing Initial Directory for $SERVER_DIRECTORY/backup..."
        #drive push -no-prompt -quiet -directories "$SERVER_DIRECTORY/backup"
        drive push -no-prompt -directories "$SERVER_DIRECTORY/backup"

        VARIABLE_START_FRESH=$(promptFunction "[Google Drive] Pull Down Latest Server Backup or Start Fresh? (y for Latest Backup) (n for Start Fresh) " "y" "10")

        if [ "$VARIABLE_START_FRESH" = "TRUE" ]
        then
            cd "$SERVER_DIRECTORY"
            drive pull -no-prompt -quiet server.tar.gz
            tar -xf server.tar.gz
            rm $SERVER_DIRECTORY/*.tar.gz
        fi
    fi
}

function server_stop()
{
    echo "[Drive][ERROR] If you are seeing this message the server_stop function has not been implemented on one of the main_servername.sh scripts"
}

function server_start()
{
    echo "[Drive][ERROR] If you are seeing this message the server_start function has not been implemented on one of the main_servername.sh scripts"
}

function drive_sync_reauth()
{
    VARIABLE_GOOGLE_DRIVE_REAUTHORIZE=$(promptFunction "[Google Drive] Re-Authorize Google Drive?" "n" "10")

    if [ "$VARIABLE_GOOGLE_DRIVE_REAUTHORIZE" = "TRUE" ]
    then
        drive deinit /opt
        drive init /opt
    fi
}

export -f drive_sync_reauth

function drive_sync_main()
{
    echo "[Google Drive] Prompting for Optional Re-Auth ..."
    drive_sync_reauth

    echo "[Google Drive] Stopping Server ..."
    server_stop

    echo "[Google Drive] Syncing Write Cache to Disk ..."
    syncWriteCacheToDisk

    ##############################################################
    #### BEGIN - Check if Backup has occurred within 24 hours ####
    ##############################################################

    VARIABLE_BACKED_UP_RECENTLY="/opt/.drive_last_backup_time"
    VARIABLE_BACKED_UP_MINUTES_MAXIMUM="1440" # 60 minutes * 24 hours = 1440 minutes

    # If the File Doesn't exist then chances are this is a fresh server instance with no need for backups
    if [ ! -f "$VARIABLE_BACKED_UP_RECENTLY" ] 
    then
        touch "$VARIABLE_BACKED_UP_RECENTLY"
        chmod 777 "$VARIABLE_BACKED_UP_RECENTLY"
        echo "Easter Egg 4 U!" > "$VARIABLE_BACKED_UP_RECENTLY"
        echo "Thanks for learning my implementation!" >> "$VARIABLE_BACKED_UP_RECENTLY"
    fi

    if test "`find $VARIABLE_BACKED_UP_RECENTLY -mmin +$VARIABLE_BACKED_UP_MINUTES_MAXIMUM`"
    then
        echo "[Google Drive] [Backing Up] Last Backup Time is Greater than $VARIABLE_BACKED_UP_MINUTES_MAXIMUM Minutes - Backing up!"
        echo "Easter Egg 4 U!" > "$VARIABLE_BACKED_UP_RECENTLY"
        echo "Thanks for learning my implementation!" >> "$VARIABLE_BACKED_UP_RECENTLY"
    else
        echo "[Google Drive] [Skipping] Last Backup Time is Less than $VARIABLE_BACKED_UP_MINUTES_MAXIMUM Minutes - Skipping!"
        server_start
        return
    fi

    ############################################################
    #### END - Check if Backup has occurred within 24 hours ####
    ############################################################
    
    VARIABLE_TEMP="$SERVER_DIRECTORY/temp"
    VARIABLE_SERVER_TEMP="$VARIABLE_TEMP/server"

    VARIABLE_SERVER="$SERVER_DIRECTORY/server"
    VARIABLE_SERVER_TAR_GZ="$SERVER_DIRECTORY/server.tar.gz"

    cd "$SERVER_DIRECTORY"

    echo "[Google Drive] Removing Old $VARIABLE_SERVER_TAR_GZ..."
    rm -f "$VARIABLE_SERVER_TAR_GZ"

    echo "[Google Drive] Creating new $VARIABLE_TEMP if it doesn't exist..."
    mkdir -p "$VARIABLE_TEMP"
    mkdir -p "$VARIABLE_SERVER_TEMP"

    echo "[Google Drive] Copying $VARIABLE_SERVER to $VARIABLE_SERVER_TEMP ..."
    rsync -avu --delete "$VARIABLE_SERVER/" "$VARIABLE_SERVER_TEMP"

    echo "[Google Drive] Starting Server Back Up ..."
    server_start &

    echo "[Google Drive] Creating New $VARIABLE_SERVER_TAR_GZ from $VARIABLE_TEMP/server..."
    cd "$VARIABLE_TEMP"
    tar -zcf "$VARIABLE_SERVER_TAR_GZ" server/

    if [ -f "/opt/.drive_enabled" ] 
    then 
        # push archive to drive
        echo "[Google Drive] Deleting Old Server Tar from Drive..."
        cd "$SERVER_DIRECTORY"
        drive trash -quiet server.tar.gz
        echo "[Google Drive] Pushing New Server Tar to Drive..."
        drive push -no-prompt -quiet server.tar.gz
    fi

    if [ -f "/opt/.drive_enabled" ] 
    then 
        echo "[Google Drive] Copying Timestamped Server Archive to Drive Backup Folder Remotely..."
        cd "$SERVER_DIRECTORY"
        DATE_STAMP=`date "+%Y-%m-%d-%H_%M"`
        drive copy "./server.tar.gz" "./backup/server_$DATE_STAMP.tar.gz"
    fi
}

export -f drive_sync_main