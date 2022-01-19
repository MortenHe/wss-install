#!/bin/bash

#Hifiberry Audio Card
BOOT_CONFIG_FILE=/boot/config.txt
echo 'set HIFIBERRY audio card'
sed 's/dtparam=audio=on/dtoverlay=hifiberry-dacplus/' -i ${BOOT_CONFIG_FILE}
echo

#gleichzeitiges Abspielen von Musik und Button beep
echo 'enable simultaneous playback (music + button beep)'
cp asound.conf /etc/asound.conf
sed "$ a #enable simultaneous playback" -i ${BOOT_CONFIG_FILE}
sed "$ a dtoverlay=i2s-mmap" -i ${BOOT_CONFIG_FILE}
echo

echo 'reboot'