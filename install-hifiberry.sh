#!/bin/bash

#Hifiberry Audio Card
echo 'set HIFIBERRY audio card'
sed 's/dtparam=audio=on/dtoverlay=hifiberry-dacplus/' -i /boot/config.txt