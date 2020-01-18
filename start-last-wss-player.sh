#!/bin/bash

#get command to start the last used player
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. "${DIR}/last-player"
echo "${AUTOSTART}"