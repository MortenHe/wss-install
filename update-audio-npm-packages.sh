#!/bin/sh

#read values from config file in this dir
. $(dirname "$0")/config

#Audio Server NPM packages updaten
echo 'install AudioServer npm packages'
npm install --prefix /home/pi/mh_prog/AudioServer
echo

#SH Audio Server NPM packages updaten
echo 'install NewSHAudioServer npm packages'
npm install --prefix /home/pi/mh_prog/NewSHAudioServer
echo

#SoundQuiz Server NPM packages updaten
echo 'install SoundQuizServer npm packages'
npm install --prefix /home/pi/mh_prog/SoundQuizServer
echo

#GPIO Buttons NPM packages updaten
if [ $GPIOBUTTONS = true ];
then
  echo 'install WSGpioButtons npm packages'
  npm install --prefix /home/pi/mh_prog/WSGpioButtons
  echo
fi

#USB RFID Reader NPM packages updaten
if [ $USBRFIDREADER = true ];
then
  echo 'install WSRFID npm packages'
  npm install --prefix /home/pi/mh_prog/WSRFID
  echo
fi