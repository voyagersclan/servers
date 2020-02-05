function setupDrive()
{
    VARIABLE_GOOGLE_DRIVE_ENABLED=$(promptFunction "[Google Drive] Enable Sync Functionality?")
    
    rm -Rf /opt/.gd

    misc_findReplace "GOOGLE_DRIVE_ENABLED=\"$GOOGLE_DRIVE_ENABLED\"" "GOOGLE_DRIVE_ENABLED=\"$VARIABLE_GOOGLE_DRIVE_ENABLED\"" "$HOME/.main/main.sh"
    export GOOGLE_DRIVE_ENABLED="$VARIABLE_GOOGLE_DRIVE_ENABLED"

    if [ "$VARIABLE_GOOGLE_DRIVE_ENABLED" = "FALSE" ]
    then
        mkdir -p /opt/.gd
    fi

    if [ "$VARIABLE_GOOGLE_DRIVE_ENABLED" = "TRUE" ]
    then
        drive init /opt

        mkdir -p "$SERVER_DIRECTORY"
        mkdir -p "$SERVER_DIRECTORY/backup"

        drive push -no-prompt -quiet -directories "$SERVER_DIRECTORY"
        drive push -no-prompt -quiet -directories "$SERVER_DIRECTORY/backup"

        VARIABLE_START_FRESH=$(promptFunction "[Google Drive] Pull Down Latest Server Backup or Start Fresh? (y for Latest Backup) (n for Start Fresh) ")

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
    sendCommandToScreen "$SCREEN_NAME" " "
    echo "Shutting Down Server..."
    sendCommandToScreen "$SCREEN_NAME" "quit"

    waitForScreenTermination "$SCREEN_NAME"
}

function server_start()
{
    # resume autosaving on server
    echo "Starting Server Back Up..."
    main_process "FALSE"
}

function drive_sync_main()
{
    server_stop

    syncWriteCacheToDisk

    cd "$SERVER_DIRECTORY"

    # archive server directory
    echo "Removing Old Server Tar..."
    rm -f $SERVER_DIRECTORY/server.tar.gz
    echo "Creating New Server Tar..."
    tar -zcf $SERVER_DIRECTORY/server.tar.gz server/

    server_start

    cd "$SERVER_DIRECTORY"

    if [ "$GOOGLE_DRIVE_ENABLED" = "TRUE" ]
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
    
    if [ "$GOOGLE_DRIVE_ENABLED" = "TRUE" ]
    then 
        echo "Pushing Timestamped Server Archive to Drive..."
        drive push -no-prompt -quiet server_$DATE_STAMP.tar.gz
    fi

    #Delete backups older than 60 days
    echo "Deleting Backups Older Than 60 Days..."

    if [ "$GOOGLE_DRIVE_ENABLED" = "TRUE" ]
    then 
        find $SERVER_DIRECTORY/backup -type f -mtime +60 -exec drive trash -quiet '{}' \;
    fi

    find $SERVER_DIRECTORY/backup -type f -mtime +60 -delete 
}