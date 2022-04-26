#!/bin/sh
# Copyright 2021-2022 logsight.ai

home="$(cd -- "$(dirname -- "$0")"; pwd)"
set -e

license_missing() {
    echo "Logsight license not accepted. You need to accept the EULA when installing logsight."
    echo "Please set the first command line argument for this script to 'accept-license'"
    echo "Run installation: ./install.sh accept-license"
    echo ""
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

print_pw_requirements() {
    echo "Set $1 password:">&2
    echo " -minimum 6 characters">&2
    echo " -allowed characters [a-zA-Z0-9]">&2
    echo " -a password consisting of numbers only is not allowed">&2
}

wait_for_logsight() {
    WAIT_FOR_TIME=$1
    echo "Waiting until all services are ready...">&2
    sleep $WAIT_FOR_TIME
    echo "Setting up database...">&2
    sleep $WAIT_FOR_TIME
    echo "Creating default user space...">&2
    sleep $WAIT_FOR_TIME
}