#!/bin/sh

#Installtion-Dir fuer Video Server ect. aus aktuellem Verzeichnis ableiten
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROG_DIR="${DIR}/..";

#Video Server NPM packages updaten
echo 'install VideoServer npm packages'
npm ci --prefix ${PROG_DIR}/VideoServer --no-fund
echo