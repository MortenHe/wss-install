#!/bin/sh

#read values from config file
. ./config

#Audio Server NPM packages updaten
echo 'update AudioServer npm packages'
npm update --prefix /home/pi/mh_prog/AudioServer

#SH Audio Server NPM packages updaten
echo 'update NewSHAudioServer npm packages'
npm update --prefix /home/pi/mh_prog/NewSHAudioServer

#GPIO Buttons NPM packages updaten
if [ $GPIOBUTTONS = true ];
then
  echo 'update WSGpioButtons npm packages'
  npm update --prefix /home/pi/mh_prog/WSGpioButtons
fi

#USB RFID Reader NPM packages updaten
if [ $USBRFIDREADER = true ];
then
  echo 'update WSRFID npm packages'
  npm update --prefix /home/pi/mh_prog/WSRFID
fi