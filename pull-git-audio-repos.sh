#!/bin/bash

#Installtion-Dir fuer Audio Server ect. aus aktuellem Verzeichnis ableiten
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROG_DIR="${DIR}/..";

#read values from config file in this dir
. ${DIR}/config

#WSS Install git pull
echo 'pull wss-install git repo'
git -C ${PROG_DIR}/wss-install pull
echo

#Audio Server git pull
echo 'pull AudioServer git repo'
git -C ${PROG_DIR}/AudioServer pull
echo

#SH Audio Server git pull
echo 'pull NewSHAudioServer git repo'
git -C ${PROG_DIR}/NewSHAudioServer pull
echo

#SoundQuiz Server git pull
echo 'pull SoundQuizServer git repo'
git -C ${PROG_DIR}/SoundQuizServer pull
echo

#GPIO Buttons git pull
if [ $GPIOBUTTONS = true ];
then
  echo 'pull WSGpioButtons git repo'
  git -C ${PROG_DIR}/WSGpioButtons pull
  echo
fi

#USB RFID Reader NPM git pull
if [ $USBRFIDREADER = true ];
then
  echo 'pull WSRFID git repo'
  git -C ${PROG_DIR}/WSRFID pull
  echo
fi