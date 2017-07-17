#!/bin/sh
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description launch script for confluence

# abort when trying to use unset variable
set -o nounset

/opt/atlassian/confluence/bin/catalina.sh run
