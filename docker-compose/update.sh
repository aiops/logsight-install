#!/bin/sh
# Copyright 2021-2022 logsight.ai

home="$(cd -- "$(dirname -- "$0")"; pwd)"
set -e

export WAIT_FOR_TIME=10

. "$home/bashlib/utils.sh"

promt_install_logsight() {
    printf "Do you want to install logsight? (y/n) ">&2
    read UNINSTALL
    while ! echo "$UNINSTALL" | grep -qP '(?=^[y|n]$)'; do
        printf "Please enter 'y' or 'n': ">&2
        read UNINSTALL
    done
    echo $UNINSTALL
}

check_logsight_services_running_while_update() {
    DOCKER_COMPOSE_CMD="$1"
    cd "$home/docker-compose"
    running="$($DOCKER_COMPOSE_CMD ps --services --filter "status=running")"
    if [ ! -z "$running" ]; then
        UNINSTALL=""
    else
        echo "logsight services are not installed.">&2
        UNINSTALL="$(promt_install_logsight)"
    fi
    cd "$home"
    echo $UNINSTALL
}

# Check if the preconditions to install logsight are met
check_docker
# Check docker compose and set the docker compose command variable
DOCKER_COMPOSE_CMD="$(check_docker_compose)"

# Check if the EULA licens was accepted
if [ "$#" -lt 1 ]; then
    license_missing
fi
check_license "$1"
export ACCEPT_LOGSIGHT_LICENSE="$1"

install=$(check_logsight_services_running_while_update "$DOCKER_COMPOSE_CMD")
if [ "$install" = "y" ]; then
    echo "installing logsight..."
    "$home/install.sh" "$ACCEPT_LOGSIGHT_LICENSE"
    if [ $? -ne 0 ]; then
        echo "error during installation of logsight."
        exit 1
    fi
elif [ "$install" = "n" ]; then
    echo "logsight must be installated before updateing"
    exit 0
fi

if [ ! -f "$home/docker-compose/.pw.env" ]; then
    echo "the password file $home/docker-compose/.pw.env does not exist. cannot contunue the update process."
    echo "this is probably due to an depricated installation of logsight. please try to reinstall logsight."
    exit 1
fi

cd "$home/docker-compose"
. "./.pw.env"
$DOCKER_COMPOSE_CMD up -d
cd "$home"
if [ $? -eq 0 ]; then
    echo ""
    wait_for_logsight $WAIT_FOR_TIME
    echo ""
    echo "Logsight.ai was successfully updated. You can access http://localhost:4200"
    echo ""
fi
