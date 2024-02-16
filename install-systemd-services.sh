#!/bin/bash

SERVICES_PATH="/etc/systemd/system"

if [ "$EUID" -ne 0 ]
    then echo "This script must be run as root"
    exit
fi

DOCKER_PATH=$(which docker)
SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source $SCRIPT_PATH/.env

homeLabService="[Unit]
Description=home-lab service with docker compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=true
WorkingDirectory=$SCRIPT_PATH/
ExecStart=$DOCKER_PATH compose up -d
ExecStop=$DOCKER_PATH compose down
Restart=on-failure

[Install]
WantedBy=multi-user.target"

function installService() {
    local serviceName=$1
    local serviceContent=$2

    echo $serviceContent

    echo "Installing $serviceName service"

    touch $SERVICES_PATH/$serviceName.service
    echo "$serviceContent" > $SERVICES_PATH/$serviceName.service

    systemctl daemon-reload
    systemctl enable $serviceName.service
}

function removeService() {
    local serviceName=$1

    echo "Removing $serviceName service"

    systemctl stop $serviceName.service
    systemctl disable $serviceName.service
    rm $SERVICES_PATH/$serviceName.service
    systemctl daemon-reload
}

title="Hello! This is a script to install systemd services for home-lab"
title=""
prompt="Pick an option:"
options=(
    "Install home-lab service"
    "Remove home-lab service"
)

echo "$title"
PS3="$prompt "
select opt in "${options[@]}" "Quit"; do 
    case "$REPLY" in
    1) installService home-lab "$homeLabService";;
    2) removeService home-lab;;
    $((${#options[@]}+1))) echo "Goodbye!"; break;;
    *) echo "Invalid option. Try another one.";continue;;
    esac
done
