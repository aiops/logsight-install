#!/bin/sh
# Copyright 2021-2022 logsight.ai

home="$(cd -- "$(dirname -- "$0")"; pwd)"
set -e

. "$home/bashlib/utils.sh"

# Check if the preconditions to install logsight are met
check_docker
# Check docker compose and set the docker compose command variable
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
