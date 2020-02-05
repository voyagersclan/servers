#!/bin/bash

CONTAINER_NAME="garrys_mod"
IMAGE_NAME="voyagers:garrys_mod"
STEAM_PORT_MAPPING="27015:27015"

docker kill $CONTAINER_NAME
docker stop $CONTAINER_NAME
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME

#Use below to test and look at file structure
#docker run -it --rm voyagers:garrys_mod bash

#Initialize for First Start
if [ ! "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    docker run -it --name $CONTAINER_NAME -p "$STEAM_PORT_MAPPING" $IMAGE_NAME
fi

docker start $CONTAINER_NAME
docker logs -f $CONTAINER_NAME