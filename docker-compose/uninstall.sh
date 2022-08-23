#!/bin/sh
# Copyright 2021-2022 logsight.ai

home="$(cd -- "$(dirname -- "$0")"; pwd)"
set -e

. "$home/bashlib/utils.sh"

prompt_delete_volumes() {
    printf "Do you want to delete all logsight data? CAUTION: Doing this might result in loss of imported data. (y/n) ">&2
    read -r DEL_VOLUMES
    while ! echo "$DEL_VOLUMES" | grep -Eq '^[y|n]$'; do
        printf "Please enter 'y' or 'n': ">&2
        read -r DEL_VOLUMES
    done
    echo "$DEL_VOLUMES"
}

prompt_delete_images() {
    printf "Do you want to delete the logsight docker images? (y/n) ">&2
    read -r DEL_IMAGES
    while ! echo "$DEL_IMAGES" | grep -Eq '^[y|n]$'; do
        printf "Please enter 'y' or 'n': ">&2
        read -r DEL_IMAGES
    done
    echo "$DEL_IMAGES"
}

# Check if the preconditions to install logsight are met
check_docker
# Check docker compose and set the docker compose command variable
DOCKER_COMPOSE_CMD="$(check_docker_compose)"

export ELASTICSEARCH_PASSWORD=""
export POSTGRES_PASSWORD=""
export ACCEPT_LOGSIGHT_LICENSE=""

args="down" 

del_volumes=$(prompt_delete_volumes)
if [ "$del_volumes" = "y" ]; then
    args="$args -v"
fi

del_images=$(prompt_delete_images)
if [ "$del_images" = "y" ]; then
    args="$args --rmi all"
fi

echo "Uninstalling logsight..."
cd "$home/docker-compose"


if  eval "$DOCKER_COMPOSE_CMD $args"; then
    echo "Uninstall logsight successful."
else
    echo "Uninstall logsight went wrong."
fi 

cd "$home"
