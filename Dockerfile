FROM debian:stretch

USER root

#Install Misc Dependencies
RUN apt-get update &&\
    apt-get install -y curl git screen openjdk-8-jre-headless software-properties-common dirmngr apt-transport-https vim python3 python3-pip &&\ 
    apt-get clean all

RUN  pip3 install requests

#Install Google Drive Application
RUN apt-add-repository 'deb http://shaggytwodope.github.io/repo ./' &&\
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7086E9CC7EC3233B &&\
    apt-get update &&\
    apt-get install -y drive &&\
    apt-get clean all

#Install Steam Dependencies
RUN echo 'deb http://mirrors.linode.com/debian stretch main non-free' >> /etc/apt/sources.list &&\
    echo 'deb-src http://mirrors.linode.com/debian stretch main non-free' >> /etc/apt/sources.list &&\
    dpkg --add-architecture i386 &&\
    apt-get update &&\
    echo steam steam/question select "I AGREE" | debconf-set-selections &&\
    echo steam steam/license note '' | debconf-set-selections &&\
    apt-get install -y lib32gcc1 steamcmd &&\
    apt-get clean all

#Debian Specific Fix for Steam
#Error for Dump Uploads to Steam Central Requires 32bit curl instead of 64bit curl
RUN apt-get update &&\
    dpkg -l | grep curl &&\
    dpkg --add-architecture i386 &&\
    apt install libcurl3-gnutls:i386 -y && apt update -y && apt upgrade -y &&\
    dpkg -l | grep curl | grep 386 &&\
    apt-get clean all 

#Debian Specific Fix for Steam
#Error for en_US.UTF-8 issue
RUN apt-get update &&\
    apt-get install -y locales && \
    echo "US/Eastern" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    apt-get clean all 

#Begin Customization
ARG SERVER_NAME
ARG SERVER_USER_NAME

ENV SCREEN_NAME "$SERVER_NAME"
ENV SCREEN_LOG "$SERVER_NAME.out"
ENV SERVER_DIRECTORY "/opt/$SERVER_NAME"

ARG STEAM_GAME
ENV STEAM_GAME "$STEAM_GAME"

ARG STEAM_APP_ID
ENV STEAM_APP_ID "$STEAM_APP_ID"

ARG STEAM_NAME_ID
ENV STEAM_NAME_ID "$STEAM_NAME_ID"

#Setup Directories for Server
RUN mkdir ${SERVER_DIRECTORY} &&\
    mkdir ${SERVER_DIRECTORY}/backup &&\
    adduser --system --home ${SERVER_DIRECTORY} --shell /bin/bash --group ${SERVER_USER_NAME} &&\
    chown -R ${SERVER_USER_NAME}:${SERVER_USER_NAME} /opt/


#Move Functions To Proper Place
COPY functions/ ${SERVER_DIRECTORY}/.functions/
RUN chown ${SERVER_USER_NAME}:${SERVER_USER_NAME} -R ${SERVER_DIRECTORY}/.functions/ &&\
    chmod -R 755 ${SERVER_DIRECTORY}/.functions/

#Move Main Scripts To Proper Place
COPY main/ ${SERVER_DIRECTORY}/.main/
RUN chown ${SERVER_USER_NAME}:${SERVER_USER_NAME} -R ${SERVER_DIRECTORY}/.main/ &&\
    chmod -R 755 ${SERVER_DIRECTORY}/.main/

USER ${SERVER_USER_NAME}
CMD bash -c ${SERVER_DIRECTORY}/.main/main.sh
