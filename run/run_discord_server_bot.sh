#!/bin/bash

CONTAINER_NAME="discord_server_bot"
IMAGE_NAME="voyagers:discord_server_bot"
USE_STEAM_MOUNTS="FALSE"
USE_VOLUMES="FALSE"

declare -A PORT_MAPPING_LIST
PORT_MAPPING_LIST+=(["2225"]="22")
PORT_MAPPING_LIST+=(["8083"]="8080")

./run/run.sh $CONTAINER_NAME $IMAGE_NAME $USE_VOLUMES $USE_STEAM_MOUNTS "$(declare -p PORT_MAPPING_LIST)"