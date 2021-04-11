#!/bin/bash

#Installtion-Dir fuer Audio Server ect. aus aktuellem Verzeichnis ableiten
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROG_DIR="${DIR}/..";

echo 'get and install MAUSBERRY power button script'
wget http://files.mausberrycircuits.com/setup.sh -P ${PROG_DIR}
bash ${PROG_DIR}/setup.sh