#!/bin/bash

CONTAINER_NAME="garrys_mod"
IMAGE_NAME="voyagers:garrys_mod"
STEAM_PORT_MAPPING="27015:27015"

# docker kill $CONTAINER_NAME
# docker stop $CONTAINER_NAME
# docker stop $CONTAINER_NAME
# docker rm $CONTAINER_NAME

#-p 8080:80/tcp -p 8080:80/udp	

#Use below to test and look at file structure
#docker run -it --rm voyagers:garrys_mod bash

#Initialize for First Start
if [ ! "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    #Logic to detect if this is a windows or linux box
    if [ "$(expr substr $(uname -s) 1 10)" = "MINGW32_NT" ] || [ "$(expr substr $(uname -s) 1 10)" = "MINGW64_NT" ]; then
        #Not use mounts if on windows box
        docker run -it --name $CONTAINER_NAME -p "$STEAM_PORT_MAPPING" -p "$STEAM_PORT_MAPPING/tcp" -p "$STEAM_PORT_MAPPING/udp" $IMAGE_NAME
    else
        #Use Mounts if on Linux Box
        docker run -it -v /opt/mounts:/opt/garrys_mod/mounts --name $CONTAINER_NAME -p "$STEAM_PORT_MAPPING/tcp" -p "$STEAM_PORT_MAPPING/udp" $IMAGE_NAME
    fi
fi

docker start $CONTAINER_NAME
docker logs -f $CONTAINER_NAME