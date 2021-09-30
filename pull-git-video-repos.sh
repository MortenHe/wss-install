#!/bin/sh

#Installtion-Dir fuer Video Server ect. aus aktuellem Verzeichnis ableiten
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROG_DIR="${DIR}/..";

#WSS Install git pull
echo 'pull wss-install git repo'
git -C ${PROG_DIR}/wss-install pull
echo

#Video Server git pull
echo 'pull VideoServer git repo'
git -C ${PROG_DIR}/VideoServer pull
echo