#!/bin/bash

#Gather Passed in Parameters for Usage
CONTAINER_NAME=$1; shift
IMAGE_NAME=$1; shift
USE_VOLUMES=$1; shift
USE_STEAM_MOUNTS=$1; shift
eval "declare -A PORT_MAPPING_LIST="${1#*=}

######################################
####Declare Misc Utility Functions####
######################################

function promptFunction()
{
    MESSAGE_TO_DISPLAY="$1"

    VARIABLE_RESPONSE_TO_RETURN="FALSE"
    
    while true; do
        read -p "$MESSAGE_TO_DISPLAY" yn
        case $yn in
            [Yy]* ) VARIABLE_RESPONSE_TO_RETURN="TRUE"; break;;
            [Nn]* ) VARIABLE_RESPONSE_TO_RETURN="FALSE"; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done

    echo $VARIABLE_RESPONSE_TO_RETURN
}

#################################
####Check if Windows or Linux####
#################################

IS_LINUX="FALSE"
IS_WINDOWS="FALSE"

if [ "$(expr substr $(uname -s) 1 10)" = "MINGW32_NT" ] || [ "$(expr substr $(uname -s) 1 10)" = "MINGW64_NT" ]; then
    IS_WINDOWS="TRUE"
    IS_LINUX="FALSE"
else
    IS_WINDOWS="FALSE"
    IS_LINUX="TRUE"
fi

##################################################################
####Declare Arg String for Concatenation and Usage with Docker####
##################################################################
COMMAND_TO_EXECUTE="docker run "


######################################
####Check if Volumes are used     ####
######################################

if [ "$IS_LINUX" = "TRUE" ] && [ "$USE_VOLUMES" = "TRUE" ];
then
    LOCAL_MOUNT="/opt/volumes/$CONTAINER_NAME"
    REMOTE_MOUNT="/opt"

    mkdir -p $LOCAL_MOUNT
    chmod 777 $LOCAL_MOUNT

    COMMAND_TO_EXECUTE+="-v $LOCAL_MOUNT:$REMOTE_MOUNT "
fi

######################################
####Check if Steam Mounts are used####
######################################

if [ "$USE_STEAM_MOUNTS" = "TRUE" ] && [ "$IS_LINUX" = "TRUE" ] && [ "$USE_VOLUMES" = "TRUE" ];
then
    COMMAND_TO_EXECUTE+="-v /opt/mounts:/opt/$CONTAINER_NAME/.mounts "
fi

##########################
####Add Container Name####
##########################

COMMAND_TO_EXECUTE+="--name $CONTAINER_NAME "

#####################################################################
####Iterate the Port Mapping Array and create the Port Arg String####
#####################################################################

for LOCAL_LISTEN_PORT in "${!PORT_MAPPING_LIST[@]}"
do
    DESTINATION_PORT=${DESTINATION_LIST[$LOCAL_LISTEN_PORT]}
    COMMAND_TO_EXECUTE+="-p \"$LOCAL_LISTEN_PORT:$DESTINATION_PORT\" "
done

######################
####Add Image Name####
######################

COMMAND_TO_EXECUTE+="$IMAGE_NAME "

############################################################
####Push Current Existing Containers Server to the Cloud####
############################################################

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    VARIABLE_PUSH_TO_CLOUD=$(promptFunction "[Drive] Do you want to push the current server contents to the cloud? (Y for Push) (N for Nope)")

    if [ "$VARIABLE_PUSH_TO_CLOUD" = "TRUE" ]
    then    
        COMMAND_TO_RUN="
cd

for f in .functions/*; do
    source \$f
done

source .main/main_$CONTAINER_NAME.sh

drive_sync_main
"

        docker exec -it $CONTAINER_NAME bash -c "$COMMAND_TO_RUN"
    fi
fi

############################################################################
####Determine whether or not to Completely Remove Pre-existing Container####
############################################################################

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    VARIABLE_START_FRESH=$(promptFunction "[Docker][WARNING] Do you want to Kill, Stop, and Remove the Current Container for $CONTAINER_NAME? This will delete all data in the container that has not been backed up to the cloud. (Y for Delete) (N for Keep)")

    if [ "$VARIABLE_START_FRESH" = "TRUE" ]
    then
        docker kill $CONTAINER_NAME
        docker stop $CONTAINER_NAME
        docker stop $CONTAINER_NAME
        docker rm $CONTAINER_NAME
    fi
fi

#Initialize for First Start
if [ ! "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    $COMMAND_TO_EXECUTE
fi

docker start $CONTAINER_NAME
docker logs -f $CONTAINER_NAME