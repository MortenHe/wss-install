#!/bin/sh

#WSS Install git pull
echo 'pull wss-install git repo'
git -C /home/pi/wss-install pull
echo

#Video Server git pull
echo 'pull VideoServer git repo'
git -C /home/pi/mh_prog/VideoServer pull
echo