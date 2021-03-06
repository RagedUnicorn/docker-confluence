FROM ragedunicorn/openjdk:1.2.1-jdk-stable

LABEL com.ragedunicorn.maintainer="Michael Wiesendanger <michael.wiesendanger@gmail.com>"

#     ______            ______
#    / ____/___  ____  / __/ /_  _____  ____  ________
#   / /   / __ \/ __ \/ /_/ / / / / _ \/ __ \/ ___/ _ \
#  / /___/ /_/ / / / / __/ / /_/ /  __/ / / / /__/  __/
#  \____/\____/_/ /_/_/ /_/\__,_/\___/_/ /_/\___/\___/

# image args
ARG CONFLUENCE_USER=confluence
ARG CONFLUENCE_GROUP=confluence

ENV \
  CONFLUENCE_VERSION=6.15.1 \
  POSTGRESQL_VERSION=11.2-r0 \
  SU_EXEC_VERSION=0.2-r0 \
  XMLSTARLET_VERSION=1.6.1-r0 \
  GCOMPAT_VERSION=0.3.0-r0 \
  LIBC6_COMPAT_VERSION=1.1.20-r4 \
  TTF_DEJAVU_VERSION=2.37-r1 \
  BASH_VERSION=4.4.19-r1

ENV \
  CONFLUENCE_USER="${CONFLUENCE_USER}" \
  CONFLUENCE_GROUP="${CONFLUENCE_GROUP}" \
  CONFLUENCE_HOME=/var/atlassian/confluence \
  CONFLUENCE_INSTALL=/opt/atlassian/confluence \
  CONFLUENCE_DATA_DIR=/var/atlassian/confluence \
  CONFLUENCE_LOGS_DIR=/opt/atlassian/confluence/logs

# explicitly set user/group IDs
RUN addgroup -S "${CONFLUENCE_GROUP}" -g 9999 && adduser -S -G "${CONFLUENCE_GROUP}" -u 9999 "${CONFLUENCE_USER}"

WORKDIR /home

RUN \
  set -ex; \
  apk add --no-cache \
    bash="${BASH_VERSION}" \
    ttf-dejavu="${TTF_DEJAVU_VERSION}" \
    libc6-compat="${LIBC6_COMPAT_VERSION}" \
    gcompat="${GCOMPAT_VERSION}" \
    xmlstarlet="${XMLSTARLET_VERSION}" \
    postgresql="${POSTGRESQL_VERSION}" \
    su-exec="${SU_EXEC_VERSION}" && \
  mkdir -p "${CONFLUENCE_HOME}" && \
  mkdir -p  "${CONFLUENCE_HOME}/caches/indexes" && \
  chmod -R 700 "${CONFLUENCE_HOME}" && \
  chown -R "${CONFLUENCE_USER}":"${CONFLUENCE_GROUP}" "${CONFLUENCE_HOME}" && \
  mkdir -p "${CONFLUENCE_INSTALL}/conf" && \
  if ! wget -q "https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz"; then \
    echo >&2 "Error: Failed to download Confluence binary"; \
    exit 1; \
  fi && \
  tar zxf atlassian-confluence-"${CONFLUENCE_VERSION}".tar.gz --directory  "${CONFLUENCE_INSTALL}" --strip-components=1 --no-same-owner && \
  if ! wget -q "https://jdbc.postgresql.org/download/postgresql-42.2.5.jar" -P "${CONFLUENCE_INSTALL}/lib/"; then \
    echo >&2 "Error: Failed to download Postgresql driver"; \
    exit 1; \
  fi && \
  chmod -R 700 "${CONFLUENCE_INSTALL}/logs" && \
  chmod -R 700 "${CONFLUENCE_INSTALL}/temp" && \
  chmod -R 700 "${CONFLUENCE_INSTALL}/work" && \
  chmod -R 700 "${CONFLUENCE_INSTALL}/conf" && \
  chown -R "${CONFLUENCE_USER}":"${CONFLUENCE_GROUP}" "${CONFLUENCE_INSTALL}/logs" && \
  chown -R "${CONFLUENCE_USER}":"${CONFLUENCE_GROUP}" "${CONFLUENCE_INSTALL}/temp" && \
  chown -R "${CONFLUENCE_USER}":"${CONFLUENCE_GROUP}" "${CONFLUENCE_INSTALL}/work" && \
  chown -R "${CONFLUENCE_USER}":"${CONFLUENCE_GROUP}" "${CONFLUENCE_INSTALL}/conf" && \
  echo -e "\nconfluence.home=${CONFLUENCE_HOME}" >> "${CONFLUENCE_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties" \
  && xmlstarlet              ed --inplace \
       --delete               "Server/@debug" \
       --delete               "Server/Service/Connector/@debug" \
       --delete               "Server/Service/Connector/@useURIValidationHack" \
       --delete               "Server/Service/Connector/@minProcessors" \
       --delete               "Server/Service/Connector/@maxProcessors" \
       --delete               "Server/Service/Engine/@debug" \
       --delete               "Server/Service/Engine/Host/@debug" \
       --delete               "Server/Service/Engine/Host/Context/@debug" \
                              "${CONFLUENCE_INSTALL}/conf/server.xml" \
   && touch -d "@0"           "${CONFLUENCE_INSTALL}/conf/server.xml"

# add healthcheck script
COPY docker-healthcheck.sh /

# add launch script
COPY docker-entrypoint.sh /

RUN \
  chmod 755 /docker-entrypoint.sh && \
  chmod 755 /docker-healthcheck.sh

EXPOSE 8090

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["${CONFLUENCE_DATA_DIR}", "${CONFLUENCE_LOGS_DIR}"]

ENTRYPOINT ["/docker-entrypoint.sh"]
