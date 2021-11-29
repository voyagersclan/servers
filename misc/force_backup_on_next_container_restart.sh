#!/bin/bash

containers=$(docker ps | awk '{if(NR>1) print $NF}')

for CONTAINER_NAME in $containers
do
    VARIABLE_DRIVE_LAST_BACKUP_TIME_FILE="/opt/.drive_last_backup_time"

    echo "[CONTAINER][$CONTAINER_NAME] Removing - $VARIABLE_DRIVE_LAST_BACKUP_TIME_FILE ... "
    docker exec -u 0 -it $CONTAINER_NAME rm $VARIABLE_DRIVE_LAST_BACKUP_TIME_FILE

    echo "[CONTAINER][$CONTAINER_NAME] Creating New File 500 hours in the past - $VARIABLE_DRIVE_LAST_BACKUP_TIME_FILE ... "
    docker exec -u 0 -it $CONTAINER_NAME touch -d "500 hours ago" $VARIABLE_DRIVE_LAST_BACKUP_TIME_FILE

    echo "[CONTAINER][$CONTAINER_NAME] Setting 777 Permissions - $VARIABLE_DRIVE_LAST_BACKUP_TIME_FILE ... "
    docker exec -u 0 -it $CONTAINER_NAME chmod 777 $VARIABLE_DRIVE_LAST_BACKUP_TIME_FILE

    echo "[CONTAINER][$CONTAINER_NAME] Restarting... "
    docker restart $CONTAINER_NAME

    docker logs -f $CONTAINER_NAME
done

