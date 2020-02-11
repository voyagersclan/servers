#!/bin/bash

#Sets the Home Directory and the Nickname of the Server in Google Drive
#Available options include garrys_mod and 
SERVER_NAME="garrys_mod"
SERVER_USER_NAME="steam"

#Sets if this is a Steam Server
STEAM_GAME="TRUE"
STEAM_APP_ID="4020"
STEAM_NAME_ID="garrysmod"

#Final Image Name
IMAGE_NAME="voyagers:garrys_mod"

DOCKER_BUILD_CONTEXT_FOLDER="."

docker rmi $IMAGE_NAME
docker build --file ./Dockerfile -t "$IMAGE_NAME" --build-arg SERVER_NAME="$SERVER_NAME" \
                                                  --build-arg SERVER_USER_NAME="$SERVER_USER_NAME" \
                                                  --build-arg STEAM_GAME="$STEAM_GAME" \
                                                  --build-arg STEAM_APP_ID="$STEAM_APP_ID" \
                                                  --build-arg STEAM_NAME_ID="$STEAM_NAME_ID" \
                                                  $DOCKER_BUILD_CONTEXT_FOLDER \
                                                  