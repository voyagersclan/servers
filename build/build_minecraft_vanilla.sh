#!/bin/bash

#Sets the Home Directory and the Nickname of the Server in Google Drive
#Available options include garrys_mod and 
SERVER_NAME="minecraft_vanilla"
SERVER_USER_NAME="mojang"

#Sets if this is a Steam Server
STEAM_GAME="FALSE"
STEAM_APP_ID="4020"
STEAM_NAME_ID="garrysmod"

#Final Image Name
IMAGE_NAME="voyagers:minecraft_vanilla"

DOCKER_BUILD_CONTEXT_FOLDER="."

docker stop $SERVER_NAME
docker rm $SERVER_NAME
#docker rmi $IMAGE_NAME
docker build --file ./Dockerfile -t "$IMAGE_NAME" --build-arg SERVER_NAME="$SERVER_NAME" \
                                                  --build-arg SERVER_USER_NAME="$SERVER_USER_NAME" \
                                                  --build-arg STEAM_GAME="$STEAM_GAME" \
                                                  --build-arg STEAM_APP_ID="$STEAM_APP_ID" \
                                                  --build-arg STEAM_NAME_ID="$STEAM_NAME_ID" \
                                                  $DOCKER_BUILD_CONTEXT_FOLDER \
                                                  