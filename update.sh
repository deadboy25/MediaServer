#!/bin/bash

#This pulls the latest images for the containers and restarts them
#
#It can be run periodically from a cronjob to keep containers up to date,
#but must be run as root or with sudo

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This script must be run as root or using sudo,"
    echo "try running the following instead:"
    echo ""
    echo "    sudo $0 $*"
    echo ""
    exit
fi

echo "Pulling latest images..."
docker compose pull

echo "Restarting containers..."
docker compose up -d
