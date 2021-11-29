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

function drive_sync_main_prompt()
{
    VARIABLE_GOOGLE_DRIVE_DO_BACKUP=$(promptFunction "[Google Drive] Backup to Google Drive?" "n" "10")

    if [ "$VARIABLE_GOOGLE_DRIVE_DO_BACKUP" = "TRUE" ]
    then
        drive_sync_main
    fi
}

export -f drive_sync_reauth

function drive_sync_main()
{
    echo "[Google Drive] Stopping Server ..."
    server_stop

    echo "[Google Drive] Syncing Write Cache to Disk ..."
    syncWriteCacheToDisk

    echo "[Google Drive] Prompting for Optional Re-Auth ..."
    drive_sync_reauth
    
    cd "$SERVER_DIRECTORY"

    # archive server directory
    echo "Removing Old Server Tar..."
    rm -f $SERVER_DIRECTORY/server.tar.gz
    echo "Creating New Server Tar..."
    tar -zcf $SERVER_DIRECTORY/server.tar.gz server/

    server_start

    cd "$SERVER_DIRECTORY"

    if [ -f "/opt/.drive_enabled" ] 
    then 
        # push archive to drive
        echo "Deleting Old Server Tar from Drive..."
        drive trash -quiet server.tar.gz
        echo "Pushing New Server Tar to Drive..."
        drive push -no-prompt -quiet server.tar.gz
    fi

    #Backup magic
    mkdir $SERVER_DIRECTORY/backup
    cd $SERVER_DIRECTORY/backup

    DATE_STAMP=`date "+%Y-%m-%d-%H_%M"`

    echo "Copying Server Tar to Timestamped Archive..."
    cp $SERVER_DIRECTORY/server.tar.gz $SERVER_DIRECTORY/backup/server_$DATE_STAMP.tar.gz
    
    if [ -f "/opt/.drive_enabled" ] 
    then 
        echo "Pushing Timestamped Server Archive to Drive..."
        drive push -no-prompt -quiet server_$DATE_STAMP.tar.gz
    fi

    #Delete backups older than 60 days
    echo "Deleting Backups Older Than 60 Days..."

    if [ -f "/opt/.drive_enabled" ] 
    then 
        find $SERVER_DIRECTORY/backup -type f -mtime +60 -exec drive trash -quiet '{}' \;
    fi

    find $SERVER_DIRECTORY/backup -type f -mtime +60 -delete 
}

export -f drive_sync_main