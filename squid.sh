#!/bin/bash

######### VARIABLES
# HERE
HERE=`pwd`

# DATE
NOW=$(date +%Y-%m-%d-%H-%M-%S)

# CONTAINER NAME
CONTAINERNAME=alpine_squid

# CONTAINER VERSION
CONTAINERVERSION=iefcufj/alpine_squid

PORT=3128

# CREATE BACKUP DIRECTORY
mkdir -p $HERE/data
mkdir -p $HERE/backup

########## INSTALL
if [ "$1" = "--install" ]; then

        # START CONTAINER
        docker run -d -p $PORT:$PORT --name $CONTAINERNAME -v $HERE/data:/data --restart=always $CONTAINERVERSION
fi

########## START
if [ "$1" = "--start" ]; then

        docker start $CONTAINERNAME
fi

########## STOP
if [ "$1" = "--stop" ]; then

        docker stop $CONTAINERNAME
fi

########## REMOVE
if [ "$1" = "--remove" ]; then

        $0 --stop
        docker rm $CONTAINERNAME
fi

########## BACKUP
if [ "$1" = "--backup" ]; then

        $0 --stop
        tar cvf $HERE/backup/$CONTAINERNAME-backup-$NOW.tar -C $HERE/data .
        $0 --start
fi

########## RESTORE
if [ "$1" = "--restore" ]; then

        $0 --stop
        rm -rf $HERE/data
        mkdir -p $HERE/data
        tar xvf $HERE/backup/`ls -t backup/$CONTAINERNAME-backup* | head -1 | sed 's/backup\///'` -C $HERE/data .
        $0 --start
fi

########## UPDATE
if [ "$1" = "--update" ]; then
        $0 --backup
        $0 --remove
        docker pull $CONTAINERVERSION
        $0 --install
fi

########## RESTART
if [ "$1" = "--restart" ]; then
        $0 --remove
        $0 --install
fi

########## BUILD
if [ "$1" = "--build" ]; then
        docker build -t $CONTAINERVERSION $HERE/.
fi
