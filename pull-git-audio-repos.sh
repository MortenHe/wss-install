#!/bin/sh

#read values from config file in this dir
. $(dirname "$0")/config

#WSS Install git pull
echo 'pull wss-install git repo'
git -C /home/pi/wss-install pull
echo

#Audio Server git pull
echo 'pull AudioServer git repo'
git -C /home/pi/mh_prog/AudioServer pull
echo

#SH Audio Server git pull
echo 'pull NewSHAudioServer git reppackages'
git -C /home/pi/mh_prog/NewSHAudioServer pull
echo

#SoundQuiz Server git pull
echo 'update SoundQuizServer npm packages'
git -C /home/pi/mh_prog/SoundQuizServer pull
echo

#GPIO Buttons git pull
if [ $GPIOBUTTONS = true ];
then
  echo 'update WSGpioButtons npm packages'
  git -C /home/pi/mh_prog/WSGpioButtons pull
  echo
fi

#USB RFID Reader NPM git pull
if [ $USBRFIDREADER = true ];
then
  echo 'update WSRFID npm packages'
  git -C /home/pi/mh_prog/WSRFID pull
  echo
fi