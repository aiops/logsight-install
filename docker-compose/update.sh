#!/bin/sh
# Copyright 2021-2022 logsight.ai

home="$(cd -- "$(dirname -- "$0")"; pwd)"
set -e

export WAIT_FOR_TIME=10

. "$home/bashlib/utils.sh"

prompt_install_logsight() {
    printf "Do you want to install logsight? (y/n) ">&2
    read -r UNINSTALL
    while ! echo "$UNINSTALL" | grep -qP '(?=^[y|n]$)'; do
        printf "Please enter 'y' or 'n': ">&2
        read -r UNINSTALL
    done
    echo "$UNINSTALL"
}

check_logsight_services_running_while_update() {
    DOCKER_COMPOSE_CMD="$1"
    cd "$home/docker-compose"
    running="$($DOCKER_COMPOSE_CMD ps --services --filter 'status=running' 2>/dev/null)"
    if [ -n "$running" ]; then
        UNINSTALL=""
    else
        echo "logsight services are not installed.">&2
        UNINSTALL="$(prompt_install_logsight)"
    fi
    cd "$home"
    echo "$UNINSTALL"
}

# Check if the preconditions to install logsight are met
check_docker
# Check docker compose and set the docker compose command variable
DOCKER_COMPOSE_CMD="$(check_docker_compose)"

# Check if the EULA license was accepted
if [ "$#" -lt 1 ]; then
    license_missing "update.sh"
fi
check_license "$1" "update.sh"
export ACCEPT_LOGSIGHT_LICENSE="$1"

install=$(check_logsight_services_running_while_update "$DOCKER_COMPOSE_CMD")
if [ "$install" = "y" ]; then
    echo "installing logsight..."

    if ! sh "$home/install.sh" "$ACCEPT_LOGSIGHT_LICENSE"; then
        echo "error during installation of logsight."
        exit 1
    fi
elif [ "$install" = "n" ]; then
    echo "logsight must be installed before updating"
    exit 0
fi

if [ ! -f "$home/docker-compose/.pw.env" ]; then
    echo "the password file $home/docker-compose/.pw.env does not exist. cannot continue the update process."
    echo "this is probably due to an deprecated installation of logsight. please try to reinstall logsight."
    exit 1
fi

cd "$home/docker-compose"
. "./.pw.env"


if ! $DOCKER_COMPOSE_CMD up -d; then
    echo ""
    wait_for_logsight $WAIT_FOR_TIME
    echo ""
    echo "Logsight.ai was successfully updated. You can access http://localhost:4200"
    echo ""
fi

cd "$home"
