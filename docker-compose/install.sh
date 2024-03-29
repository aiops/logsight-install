#!/bin/sh
# Copyright 2021-2022 logsight.ai

home="$(cd -- "$(dirname -- "$0")"; pwd)"
set -e

WAIT_FOR_TIME=45

. "$home/bashlib/utils.sh"

prompt_reinstall_or_update() {
    printf "Do you want to update or reinstall logsight? (u/r) ">&2
    read -r input
    while ! echo "$input" | grep -Eq '^[u|r]$'; do
        printf "Please enter 'u' or 'r': ">&2
        read -r input
    done
    echo "$input"
}

check_logsight_services_running_while_install() {
    DOCKER_COMPOSE_CMD="$1"
    cd "$home/docker-compose"
    REINSTALL_OR_UPDATE=""
    if ! $DOCKER_COMPOSE_CMD ps --services --filter 'status=running' 1>/dev/null; then
      exit 1
    else
      running=$($DOCKER_COMPOSE_CMD ps --services --filter 'status=running' 2>/dev/null)
      if [ -n "$running" ]; then
        echo "logsight services are already installed and running.">&2

        REINSTALL_OR_UPDATE="$(prompt_reinstall_or_update)"

    else
      REINSTALL_OR_UPDATE=""
    fi
    fi
    cd "$home"
    echo "$REINSTALL_OR_UPDATE"
}

# Check if the preconditions to install logsight are met
check_docker
# Check docker compose and set the docker compose command variable
DOCKER_COMPOSE_CMD="$(check_docker_compose)"

# Check if the EULA license was accepted
if [ "$#" -lt 1 ]; then
    license_missing "install.sh"
fi
check_license "$1" "install.sh"
export ACCEPT_LOGSIGHT_LICENSE="$1"

reinstall_or_update=$(check_logsight_services_running_while_install "$DOCKER_COMPOSE_CMD")
echo "rou" "$reinstall_or_update"

if [ "$reinstall_or_update" = "r" ]; then
    echo "uninstalling running logsight services..."
    if ! sh "$home/uninstall.sh"; then
        echo "error during uninstallation of logsight. cannot continue installation."
        exit 1
    fi
elif [ "$reinstall_or_update" = "u" ]; then
    echo "updating the current installation of logsight..."

    if ! sh "$home/update.sh" "$ACCEPT_LOGSIGHT_LICENSE"; then
        echo "error during update of logsight."
        exit 1
    fi
    exit 0
fi

# Prompt for elasticsearch password if the env variable is not set
if [ -z ${ELASTICSEARCH_PASSWORD+x} ] || ! is_password_valid "$ELASTICSEARCH_PASSWORD"; then
    print_pw_requirements "elasticsearch"
    ELASTICSEARCH_PASSWORD="$(prompt_password)"
fi
echo "export ELASTICSEARCH_PASSWORD=$ELASTICSEARCH_PASSWORD" > "$home/docker-compose/.pw.env"

# Prompt for postgres password if the env variable is not set
if [ -z ${POSTGRES_PASSWORD+x} ] || ! is_password_valid "$POSTGRES_PASSWORD"; then
    print_pw_requirements "postgres database"
    POSTGRES_PASSWORD="$(prompt_password)"
fi
echo "export POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> "$home/docker-compose/.pw.env"

cd "$home/docker-compose"
. "./.pw.env"

if ! $DOCKER_COMPOSE_CMD up -d; then
    echo ""
    wait_for_logsight $WAIT_FOR_TIME
    echo ""
    echo "Logsight.ai was successfully installed. You can access http://localhost:4200"
    echo ""
fi

cd "$home"
