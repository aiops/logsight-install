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
export ELASTICSEARCH_PASSWORD

# Promt for postgres password if the env variable is not set
if [ -z ${POSTGRES_PASSWORD+x} ]; then
    stty -echo
    printf "Choose postgres DB password: "
    read POSTGRES_PASSWORD
    stty echo
    printf "\n"
fi
export POSTGRES_PASSWORD

cd "$home/docker-compose"
docker-compose up -d
