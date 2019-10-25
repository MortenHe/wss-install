#!/bin/sh

#read values from config file
. ./config

if [ $GPIOBUTTONS = true ];
then
  echo 'get gpio buttons code from github'
fi

if [ $USBRFIDREADER = true ];
then
  echo 'get usb rfid reader code from github'
fi