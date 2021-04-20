#!/bin/bash

#TODO: 
#Add the following line to /boot/config.txt and reboot:
#dtoverlay=i2s-mmap
#copy /etc/asound
#TODO: alsamixer Gain -6dB

#Iqaudio Card
echo 'set IQAUDIO card'
sed 's/dtparam=audio=on/dtoverlay=iqaudio-dacplus/' -i /boot/config.txt