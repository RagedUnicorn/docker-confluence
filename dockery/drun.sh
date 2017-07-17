#!/bin/bash
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description run script for docker-confluence container

# abort when trying to use unset variable
set -o nounset

WD="${PWD}"

# variable setup
DOCKER_CONFLUENCE_TAG="ragedunicorn/confluence"
DOCKER_CONFLUENCE_NAME="confluence"
DOCKER_CONFLUENCE_DATA_VOLUME="confluence_data"
DOCKER_CONFLUENCE_LOGS_VOLUME="confluence_logs"
DOCKER_CONFLUENCE_ID=0

# get absolute path to script and change context to script folder
SCRIPTPATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "${SCRIPTPATH}"

# check if there is already an image created
docker inspect ${DOCKER_CONFLUENCE_NAME} &> /dev/null

if [ $? -eq 0 ]; then
  # start container
  docker start "${DOCKER_CONFLUENCE_NAME}"
else
  ## run image:
  # -v mount volume
  # -p expose port
  # -d run in detached mode
  # --name define a name for the container(optional)
  DOCKER_CONFLUENCE_ID=$(docker run \
  -v ${DOCKER_CONFLUENCE_DATA_VOLUME}:/var/atlassian/confluence \
  -v ${DOCKER_CONFLUENCE_LOGS_VOLUME}:/opt/atlassian/confluence/logs \
  -p 8090:8090 \
  -dit \
  --name "${DOCKER_CONFLUENCE_NAME}" "${DOCKER_CONFLUENCE_TAG}")
fi

if [ $? -eq 0 ]; then
  # print some info about containers
  echo "$(date) [INFO]: Container info:"
  docker inspect -f '{{ .Config.Hostname }} {{ .Name }} {{ .Config.Image }} {{ .NetworkSettings.IPAddress }}' ${DOCKER_CONFLUENCE_NAME}
else
  echo "$(date) [ERROR]: Failed to start container - ${DOCKER_CONFLUENCE_NAME}"
fi

cd "${WD}"
