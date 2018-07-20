#!/bin/bash
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description build script for docker-confluence container

set -euo pipefail

WD="${PWD}"

# variable setup
DOCKER_CONFLUENCE_TAG="ragedunicorn/confluence"
DOCKER_CONFLUENCE_NAME="confluence"
DOCKER_CONFLUENCE_DATA_VOLUME="confluence_data"
DOCKER_CONFLUENCE_LOGS_VOLUME="confluence_logs"

# get absolute path to script and change context to script folder
SCRIPTPATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "${SCRIPTPATH}"

echo "$(date) [INFO]: Building container: ${DOCKER_CONFLUENCE_NAME}"

# build confluence container
docker build -t "${DOCKER_CONFLUENCE_TAG}" ../

# check if confluence data volume already exists
docker volume inspect "${DOCKER_CONFLUENCE_DATA_VOLUME}" > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "$(date) [INFO]: Reusing existing volume: ${DOCKER_CONFLUENCE_DATA_VOLUME}"
else
  echo "$(date) [INFO]: Creating new volume: ${DOCKER_CONFLUENCE_DATA_VOLUME}"
  docker volume create --name "${DOCKER_CONFLUENCE_DATA_VOLUME}" > /dev/null
fi

# check if confluence logs volume already exists
docker volume inspect "${DOCKER_CONFLUENCE_LOGS_VOLUME}" > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "$(date) [INFO]: Reusing existing volume: ${DOCKER_CONFLUENCE_LOGS_VOLUME}"
else
  echo "$(date) [INFO]: Creating new volume: ${DOCKER_CONFLUENCE_LOGS_VOLUME}"
  docker volume create --name "${DOCKER_CONFLUENCE_LOGS_VOLUME}" > /dev/null
fi

cd "${WD}"
