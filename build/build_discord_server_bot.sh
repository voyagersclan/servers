#!/bin/bash

#Sets the Home Directory and the Nickname of the Server in Google Drive
#Available options include garrys_mod and 
SERVER_NAME="discord_server_bot"
SERVER_USER_NAME="discord"

#Sets if this is a Steam Server
STEAM_GAME="FALSE"
STEAM_APP_ID="0000"
STEAM_NAME_ID="not_applicable"

#Final Image Name
IMAGE_NAME="voyagers:discord_server_bot"

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
                                                  