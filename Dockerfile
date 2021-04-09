FROM debian:stretch

USER root

#Install Misc Dependencies
RUN apt-get update &&\
    apt-get install -y curl git screen openjdk-8-jre-headless software-properties-common dirmngr apt-transport-https vim python3 python3-pip openssh-server passwd dnsutils zip unzip wget &&\ 
    apt-get clean all

RUN pip3 install requests 

#Install Go
RUN cd ~ &&\
    wget "https://golang.org/dl/go1.16.3.linux-amd64.tar.gz" &&\
    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.3.linux-amd64.tar.gz 

ENV GOPATH /opt/go

ENV PATH $PATH:/usr/local/go/bin

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
    mkdir ${SERVER_DIRECTORY}/server &&\
    mkdir ${SERVER_DIRECTORY}/backup &&\
    adduser --system --home ${SERVER_DIRECTORY} --shell /bin/bash --group ${SERVER_USER_NAME} &&\
    chown -R ${SERVER_USER_NAME}:${SERVER_USER_NAME} /opt/


#Setup SSH Server and Dependencies
USER root
RUN mkdir /var/run/sshd &&\
    echo "y" | ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' &&\
    echo "${SERVER_USER_NAME}:password" | chpasswd

#Add VSCode
COPY assets/code-server*.tar.gz /tmp/
RUN mkdir /opt/vscode  &&\
    tar -xf /tmp/code-server*.tar.gz -C /opt/vscode --strip-components=1 &&\
    rm -f /tmp/code-server*.tar.gz &&\
    chown ${SERVER_USER_NAME}:${SERVER_USER_NAME} -R /opt/vscode &&\
    chmod -R 755 /opt/vscode

#Install Node JS
RUN curl -fsSL https://deb.nodesource.com/setup_15.x | bash - &&\
    apt-get install -y nodejs npm

#Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &&\
    unzip awscliv2.zip &&\
    ./aws/install

#Test AWS as Non-Root
USER ${SERVER_USER_NAME}
RUN aws --version

#Google Drive - Install as Non-Root
USER ${SERVER_USER_NAME}
RUN go version &&\
    go get -u github.com/odeke-em/drive/cmd/drive

#Google Drive - Test Installation
ENV PATH $PATH:$GOPATH/bin
RUN drive version

#Move Functions To Proper Place
USER root
COPY functions/ ${SERVER_DIRECTORY}/.functions/
RUN chown ${SERVER_USER_NAME}:${SERVER_USER_NAME} -R ${SERVER_DIRECTORY}/.functions/ &&\
    chmod -R 755 ${SERVER_DIRECTORY}/.functions/

#Move Main Scripts To Proper Place
USER root
COPY main/ ${SERVER_DIRECTORY}/.main/
RUN chown ${SERVER_USER_NAME}:${SERVER_USER_NAME} -R ${SERVER_DIRECTORY}/.main/ &&\
    chmod -R 755 ${SERVER_DIRECTORY}/.main/

USER ${SERVER_USER_NAME}
CMD bash -c ${SERVER_DIRECTORY}/.main/main.sh