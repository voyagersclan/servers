#!/bin/bash

containers=$(docker ps | awk '{if(NR>1) print $NF}')

for CONTAINER_NAME in $containers
do
    echo "[CONTAINER][$CONTAINER_NAME] Restarting... "
    docker restart $CONTAINER_NAME

    docker logs $CONTAINER_NAME

    echo ""
    echo "[IMPORTANT] CTRL+P then CTRL+Q to detach from STDIN on Container!"
    echo ""
    
    docker attach $CONTAINER_NAME
done