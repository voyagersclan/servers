#!/bin/bash

CONTAINER_NAME="minecraft_vanilla"
IMAGE_NAME="voyagers:minecraft_vanilla"
USE_STEAM_MOUNTS="FALSE"
USE_VOLUMES="TRUE"

declare -A PORT_MAPPING_LIST
PORT_MAPPING_LIST+=(["25565"]="25565")
PORT_MAPPING_LIST+=(["2224"]="22")

./run/run.sh $CONTAINER_NAME $IMAGE_NAME $USE_VOLUMES $USE_STEAM_MOUNTS "$(declare -p PORT_MAPPING_LIST)"