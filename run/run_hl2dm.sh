#!/bin/bash

CONTAINER_NAME="hl2dm"
IMAGE_NAME="voyagers:hl2dm"
USE_STEAM_MOUNTS="FALSE"
USE_VOLUMES="FALSE"

declare -A PORT_MAPPING_LIST
PORT_MAPPING_LIST+=(["27016"]="27015/udp")
PORT_MAPPING_LIST+=(["27016"]="27015/tcp")
PORT_MAPPING_LIST+=(["2222"]="22")

./run/run.sh $CONTAINER_NAME $IMAGE_NAME $USE_VOLUMES $USE_STEAM_MOUNTS "$(declare -p PORT_MAPPING_LIST)"