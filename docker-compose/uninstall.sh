#!/bin/sh
# Copyright 2021-2022 logsight.ai

home="$(cd -- "$(dirname -- "$0")"; pwd)"
set -e

check_docker_compose() {
    # check if docker-compose is installed
    if [ -z "$(command -v docker-compose)" ]; then
        # if not check if docker compose is working
        docker compose version > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "docker compose"
        else
            echo "Logsight.ai requires docker-compose to be uninstalled. Please install it on your system and re-run the uninstallation."
            exit 1
        fi
    else
        echo "docker-compose"
    fi
}

DOCKER_COMPOSE_CMD="$(check_docker_compose)"

export ELASTICSEARCH_PASSWORD=""
export POSTGRES_PASSWORD=""
export ACCEPT_LOGSIGHT_LICENSE=""

cd "$home/docker-compose"
$DOCKER_COMPOSE_CMD down -v --rmi 'all'

if [ $? -eq 0 ]; then
    echo "Uninstall logsight successful."
else
    echo "Uninstall logsight went wrong."
fi

cd "$home" 
