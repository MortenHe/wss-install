#!/bin/bash

#Installtion-Dir fuer Audio Server ect. aus aktuellem Verzeichnis ableiten
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROG_DIR="${DIR}/..";

echo 'get and install POWERBLOCK power button script'
wget -O - https://raw.githubusercontent.com/petrockblog/PowerBlock/master/install.sh | sudo bash