#!/bin/sh
# Copyright 2021-2022 logsight.ai

home="$(cd -- "$(dirname -- "$0")"; pwd)"
set -e

license_missing() {
    echo "Logsight license not accepted. You need to accept the EULA when installing logsight."
    echo "Please set the first command line argument for this script to 'accept-license'"
    echo "Run installation: ./install.sh accept-license"
    echo ""
    # TODO: Add print with link to license text
    exit 1
}

check_license() {
    if ! (echo "$1" | grep -Eq  ^.*accept-license.*$); then
        license_missing
    fi
}

check_dependency_installed() {
    if [ -z "$(command -v $1)" ]; then
        echo "Logsight.ai requires $1 to be installed. Please install it on your system and re-run the installation."
        exit 1
    fi
}

check_docker() {
    check_dependency_installed "docker"
}

check_docker_compose() {
    # check if docker-compose is installed
    if [ -z "$(command -v docker-compose)" ]; then
        # if not check if docker compose is working
        docker compose version > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "docker compose"
        else
            echo "Logsight.ai requires docker-compose to be installed. Please install it on your system and re-run the installation."
            exit 1
        fi
    else
        echo "docker-compose"
    fi
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

# Promt for elasticsearch password if the env variable is not set
if [ -z ${ELASTICSEARCH_PASSWORD+x} ]; then
    stty -echo
    printf "Choose elasticsearch password: "
    read ELASTICSEARCH_PASSWORD
    stty echo
    printf "\n"
fi
export ELASTICSEARCH_PASSWORD=$ELASTICSEARCH_PASSWORD

# Promt for postgres password if the env variable is not set
if [ -z ${POSTGRES_PASSWORD+x} ]; then
    stty -echo
    printf "Choose postgres DB password: "
    read POSTGRES_PASSWORD
    stty echo
    printf "\n"
fi
export POSTGRES_PASSWORD=$POSTGRES_PASSWORD

cd "$home/docker-compose"
$DOCKER_COMPOSE_CMD up -d
if [ $? -eq 0 ]; then
    echo ""
    echo "Logsight.ai was successfully installed. You can access http://localhost:4200"
fi
cd "$home"
