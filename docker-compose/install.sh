#!/bin/sh
# Copyright 2021-2022 logsight.ai

home="$(cd -- "$(dirname -- "$0")"; pwd)"
set -e

WAIT_FOR_TIME=45

. "$home/bashlib/utils.sh"

promt_reinstall_or_update() {
    printf "Do you want to update or reinstall logsight? (u/r) ">&2
    read REINSTALL_OR_UPDATE
    while ! echo "$REINSTALL_OR_UPDATE" | grep -qP '(?=^[u|r]$)'; do
        printf "Please enter 'u' or 'r': ">&2
        read REINSTALL_OR_UPDATE
    done
    echo $REINSTALL_OR_UPDATE
}

check_logsight_services_running_while_install() {
    DOCKER_COMPOSE_CMD="$1"
    cd "$home/docker-compose"
    running="$($DOCKER_COMPOSE_CMD ps --services --filter "status=running")"
    if [ ! -z "$running" ]; then
        echo "logsight services are already installed and running.">&2
        REINSTALL_OR_UPDATE="$(promt_reinstall_or_update)"
    else
        REINSTALL_OR_UPDATE=""
    fi
    cd "$home"
    echo $REINSTALL_OR_UPDATE
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

reinstall_or_update=$(check_logsight_services_running_while_install "$DOCKER_COMPOSE_CMD")
if [ "$reinstall_or_update" = "r" ]; then
    echo "uninstalling running logsight services..."
    "$home/uninstall.sh"
    if [ $? -ne 0 ]; then
        echo "error during uninstallation of logsight. cannot continue installation."
        exit 1
    fi
elif [ "$reinstall_or_update" = "u" ]; then
    echo "updating the current installation of logsight..."
    "$home/update.sh" "$ACCEPT_LOGSIGHT_LICENSE"
    if [ $? -ne 0 ]; then
        echo "error during update of logsight."
        exit 1
    fi
    exit 0
fi

# Promt for elasticsearch password if the env variable is not set
if [ -z ${ELASTICSEARCH_PASSWORD+x} ] || ! is_password_valid $ELASTICSEARCH_PASSWORD; then
    print_pw_requirements "elasticsearch"
    ELASTICSEARCH_PASSWORD="$(promt_password)"
fi
echo "export ELASTICSEARCH_PASSWORD=$ELASTICSEARCH_PASSWORD" > "$home/docker-compose/.pw.env"

# Promt for postgres password if the env variable is not set
if [ -z ${POSTGRES_PASSWORD+x} ] || ! is_password_valid $POSTGRES_PASSWORD; then
    print_pw_requirements "postgre database"
    POSTGRES_PASSWORD="$(promt_password)"
fi
echo "export POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> "$home/docker-compose/.pw.env"

cd "$home/docker-compose"
. "./.pw.env"
$DOCKER_COMPOSE_CMD up -d
cd "$home"
if [ $? -eq 0 ]; then
    echo ""
    wait_for_logsight $WAIT_FOR_TIME
    echo ""
    echo "Logsight.ai was successfully installed. You can access http://localhost:4200"
    echo ""
fi
