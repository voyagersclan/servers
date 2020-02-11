#!/bin/bash

remoteOrigin="https://github.com/voyagersclan/servers.git"

if [ "$1" = "push" ]; then
    git update-index --chmod=+x ./*/*.sh
    git add -A
    git add *
    git remote add origin "$remoteOrigin"
	echo "Type Commit Message:"
	read commitMessage
    git commit -m "$commitMessage"
    git push --force -u origin master
fi

if [ "$1" = "pull" ]; then
    git remote add origin "$remoteOrigin"
    git fetch origin master
    git reset --hard FETCH_HEAD
    git pull origin master
fi

if [ "$1" = "setup" ]; then
    git init
    git remote add origin "$remoteOrigin"
    #git pull origin master
fi