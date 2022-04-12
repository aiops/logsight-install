#!/bin/sh
# Copyright 2021-2022 logsight.ai

home="$(cd -- "$(dirname -- "$0")"; pwd)"
set -e

export WAIT_FOR_TIME=45

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
        echo "Logsight.ai requires $1 to be installed. Please install it on your system and re-run the installation.">&2
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
            echo "Logsight.ai requires docker-compose to be installed. Please install it on your system and re-run the installation.">&2
            exit 1
        fi
    else
        echo "docker-compose"
    fi
}

is_password_valid() {
    PASSWORD=$1
    if echo "$PASSWORD" | grep -qP '(?=^.{6,255}$)(?=^[a-zA-Z0-9]*$)(?=.*[a-zA-Z])'; then
        return 0  # this is valid --> true
    else
        return 1  # this is not valid --> false
    fi
}

promt_password() {
    stty -echo
    printf "Password: ">&2
    read PASSWORD
    printf "\n" >&2
    stty echo
    while ! is_password_valid "$PASSWORD"; do
        echo "Invalid password">&2
        stty -echo
        printf "Password: ">&2
        read PASSWORD
        printf "\n">&2
        stty echo
    done
    echo "###########">&2
    echo "password ok">&2
    echo "###########">&2
    echo "">&2
    echo $PASSWORD
}

promt_uninstall() {
    printf "Do you want to re-install logsight? (y/n) ">&2
    read UNINSTALL
    while ! echo "$UNINSTALL" | grep -qP '(?=^[y|n]$)'; do
        printf "Please enter 'y' or 'n': ">&2
        read UNINSTALL
    done
    echo $UNINSTALL
}

check_logsight_services_running() {
    DOCKER_COMPOSE_CMD="$1"
    cd "$home/docker-compose"
    running="$($DOCKER_COMPOSE_CMD ps --services --filter "status=running")"
    if [ ! -z "$running" ]; then
        echo "logsight services are already installed and running.">&2
        UNINSTALL="$(promt_uninstall)"
    else
        UNINSTALL=""
    fi
    cd "$home"
    echo $UNINSTALL
}

print_pw_requirements() {
    echo "Set $1 password:">&2
    echo " -minimum 6 characters">&2
    echo " -allowed characters [a-zA-Z0-9]">&2
    echo " -only numbers are not allowed">&2
}

wait_for_logsight() {
    echo "Waiting until all services are ready...">&2
    sleep $WAIT_FOR_TIME
    echo "Setting up database...">&2
    sleep $WAIT_FOR_TIME
    echo "Creating default user space...">&2
    sleep $WAIT_FOR_TIME
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

uninstall=$(check_logsight_services_running "$DOCKER_COMPOSE_CMD")
if [ "$uninstall" = "y" ]; then
    echo "uninstalling running logsight services..."
    "$home/uninstall.sh"
    if [ $? -ne 0 ]; then
        echo "error during uninstallation of logsight. cannot continue installation."
        exit 1
    fi
elif [ "$uninstall" = "n" ]; then
    echo "the currently running logsight installation must be uninstalled before re-installation"
    exit 0
fi

# Promt for elasticsearch password if the env variable is not set
if [ -z ${ELASTICSEARCH_PASSWORD+x} ] || ! is_password_valid $ELASTICSEARCH_PASSWORD; then
    print_pw_requirements "elasticsearch"
    ELASTICSEARCH_PASSWORD="$(promt_password)"
fi
export ELASTICSEARCH_PASSWORD="$ELASTICSEARCH_PASSWORD"

# Promt for postgres password if the env variable is not set
if [ -z ${POSTGRES_PASSWORD+x} ] || ! is_password_valid $POSTGRES_PASSWORD; then
    print_pw_requirements "postgre database"
    POSTGRES_PASSWORD="$(promt_password)"
fi
export POSTGRES_PASSWORD="$POSTGRES_PASSWORD"

cd "$home/docker-compose"
$DOCKER_COMPOSE_CMD up -d
cd "$home"
if [ $? -eq 0 ]; then
    echo ""
    wait_for_logsight
    echo ""
    echo "Logsight.ai was successfully installed. You can access http://localhost:4200"
    echo ""
fi
