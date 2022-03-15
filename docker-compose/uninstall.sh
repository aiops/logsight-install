#!/bin/sh
# Copyright 2021-2022 logsight.ai

home="$(cd -- "$(dirname -- "$0")"; pwd)"
cd "$home/docker-compose"

docker-compose rm --force --stop -v
docker volume rm --force $(docker volume ls -f name=logsight -q) > /dev/null 2>&1
docker network rm $(docker network ls -f name=logsight -q) > /dev/null 2>&1

echo "Uninstall logsight successful"
