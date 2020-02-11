#!/bin/bash

containers=$(docker ps | awk '{if(NR>1) print $NF}')

for CONTAINER_NAME in $containers
do
    echo "[CONTAINER][$CONTAINER_NAME] Restarting... "
    docker restart $CONTAINER_NAME

    echo "[CONTAINER][$CONTAINER_NAME] Copying Updated Scripts to Container... "
    find ./main/*.* -type f -exec docker cp '{}' $CONTAINER_NAME:/opt/$CONTAINER_NAME/.main/  \;
    find ./functions/*.* -type f -exec docker cp '{}' $CONTAINER_NAME:/opt/$CONTAINER_NAME/.functions/  \;

    echo "[CONTAINER][$CONTAINER_NAME] Setting Permissions on Updated Scripts... "
    docker exec -u 0 -it $CONTAINER_NAME chmod 777 -R //opt/$CONTAINER_NAME/.main
    docker exec -u 0 -it $CONTAINER_NAME chmod 777 -R //opt/$CONTAINER_NAME/.functions

    echo "[CONTAINER][$CONTAINER_NAME] Restarting... "
    docker restart $CONTAINER_NAME

    docker logs -f $CONTAINER_NAME
done

