#!/bin/sh

#read values from config file in this dir
. $(dirname "$0")/config

#Audio Server NPM packages updaten
echo 'update AudioServer npm packages'
npm update --prefix /home/pi/mh_prog/AudioServer
echo

#SH Audio Server NPM packages updaten
echo 'update NewSHAudioServer npm packages'
npm update --prefix /home/pi/mh_prog/NewSHAudioServer
echo

#SoundQuiz Server NPM packages updaten
echo 'update SoundQuizServer npm packages'
npm update --prefix /home/pi/mh_prog/SoundQuizServer
echo

#GPIO Buttons NPM packages updaten
if [ $GPIOBUTTONS = true ];
then
  echo 'update WSGpioButtons npm packages'
  npm update --prefix /home/pi/mh_prog/WSGpioButtons
  echo
fi

#USB RFID Reader NPM packages updaten
if [ $USBRFIDREADER = true ];
then
  echo 'update WSRFID npm packages'
  npm update --prefix /home/pi/mh_prog/WSRFID
  echo
fi