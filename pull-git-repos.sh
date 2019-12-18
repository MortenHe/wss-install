#!/bin/sh

#read values from config file in this dir
. $(dirname "$0")/config

#Audio Server git pull
echo 'pull AudioServer git repo'
git -C /home/pi/mh_prog/AudioServer pull

#SH Audio Server git pull
echo 'pull NewSHAudioServer git reppackages'
git -C /home/pi/mh_prog/NewSHAudioServer pull

#SoundQuiz Server git pull
echo 'update SoundQuizServer npm packages'
git -C /home/pi/mh_prog/SoundQuizServer pull

#GPIO Buttons git pull
if [ $GPIOBUTTONS = true ];
then
  echo 'update WSGpioButtons npm packages'
  git -C /home/pi/mh_prog/WSGpioButtons pull
fi

#USB RFID Reader NPM git pull
if [ $USBRFIDREADER = true ];
then
  echo 'update WSRFID npm packages'
  git -C /home/pi/mh_prog/WSRFID pull
fi