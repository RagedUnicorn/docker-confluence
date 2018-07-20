#!/bin/sh
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description launch script for confluence

set -euo pipefail

exec su-exec ${CONFLUENCE_USER} /opt/atlassian/confluence/bin/catalina.sh run
