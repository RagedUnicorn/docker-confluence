#!/bin/bash
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description launch script for confluence

set -euo pipefail

postgresql_app_user="/run/secrets/com.ragedunicorn.postgresql.app_user"
postgresql_app_password="/run/secrets/com.ragedunicorn.postgresql.app_user_password"

function connection_check {
  loop_limit=13
  i=1

  while true
  do
    if [ ${i} -eq ${loop_limit} ]; then
      echo "$(date) [ERROR]: Timeout error, failed to connect to PostgreSQL server"
      exit 1
    fi

    echo "$(date) [INFO]: Waiting for connection to PostgreSQL, trying ${i}/${loop_limit}..."

    if pg_isready -h "${POSTGRESQL_DATABASE_HOSTNAME}" -U "${postgresql_app_user}"; then
      break
    fi

    sleep 5
    i=$((i + 1))
  done
}

function database_check {
  if psql -h "${POSTGRESQL_DATABASE_HOSTNAME}" -U "${postgresql_app_user}" -w -lqt | cut -d \| -f 1 | grep -qw "${CONFLUENCE_DATABASE_NAME}"; then
    echo "$(date) [INFO]: Confluence database already exists"
  else
    echo "$(date) [INFO]: Creating Confluence database"
    createdb -h "${POSTGRESQL_DATABASE_HOSTNAME}" -U "${postgresql_app_user}"  -w "${CONFLUENCE_DATABASE_NAME}"
  fi
}

function setup_credentials {
  if [ -f "${postgresql_app_user}" ] && [ -f "${postgresql_app_password}" ]; then
    echo "$(date) [INFO]: Found docker secrets - using secrets"

    postgresql_app_user="$(cat ${postgresql_app_user})"
    postgresql_app_password="$(cat ${postgresql_app_password})"
  else
    echo "$(date) [INFO]: No docker secrets found - using environment variables"

    postgresql_app_user="${POSTGRESQL_APP_USER:?Missing environment variable POSTGRESQL_APP_USER}"
    postgresql_app_password="${POSTGRESQL_APP_PASSWORD:?Missing environment variable POSTGRESQL_APP_PASSWORD}"
  fi

  # used by is_pgready/createdb
  export PGPASSWORD="${postgresql_app_password}"

  unset "${POSTGRESQL_APP_USER}"
  unset "${POSTGRESQL_APP_PASSWORD}"
}

function init {
  setup_credentials
  connection_check
  database_check

  unset "${PGPASSWORD}"

  echo "$(date) [INFO]: Starting Confluence..."
  exec su-exec ${CONFLUENCE_USER} /opt/atlassian/confluence/bin/start-confluence.sh -fg
}

init
