#!/bin/bash

#Installtion-Dir fuer Audio Server ect. aus aktuellem Verzeichnis ableiten
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROG_DIR="${DIR}/..";

#read values from config file in this dir
. ${DIR}/config

#Audio Server NPM packages updaten
echo 'install AudioServer npm packages'
npm ci --prefix ${PROG_DIR}/AudioServer --no-fund
echo

#SH Audio Server NPM packages updaten
echo 'install NewSHAudioServer npm packages'
npm ci --prefix ${PROG_DIR}/NewSHAudioServer --no-fund
echo

#SoundQuiz Server NPM packages updaten
echo 'install SoundQuizServer npm packages'
npm ci --prefix ${PROG_DIR}/SoundQuizServer --no-fund
echo

#GPIO Buttons NPM packages updaten
if [ $GPIOBUTTONS = true ];
then
  echo 'install WSGpioButtons npm packages'
  npm ci --prefix ${PROG_DIR}/WSGpioButtons --no-fund
  echo
fi

#USB RFID Reader NPM packages updaten
if [ $USBRFIDREADER = true ];
then
  echo 'install WSRFID npm packages'
  npm ci --prefix ${PROG_DIR}/WSRFID --no-fund
  echo
fi

#STT NPM packages updaten
if [ $STT = true ];
then
  echo 'install WSSTT npm packages'
  npm ci --prefix ${PROG_DIR}/WSSTT --no-fund
  echo
fi