#!/bin/bash

#Iqaudio Card
echo 'set IQAUDIO card'
sed 's/dtparam=audio=on/dtoverlay=iqaudio-dacplus/' -i /boot/config.txt