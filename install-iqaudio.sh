#!/bin/bash

#Iqaudio Card
BOOT_CONFIG_FILE=/boot/config.txt
echo 'set IQAUDIO audio card'
sed 's/dtparam=audio=on/dtoverlay=iqaudio-dacplus/' -i /boot/config.txt
echo

#gleichzeitiges Abspielen von Musik und Button beep
echo 'enable simultaneous playback (music + button beep)'
cp asound.conf /etc/asound.conf
sed "$ a #enable simultaneous playback" -i ${BOOT_CONFIG_FILE}
sed "$ a dtoverlay=i2s-mmap" -i ${BOOT_CONFIG_FILE}
echo

#TODO: alsamixer Gain -6dB`
echo 'reboot'