#!/bin/sh

#Audio Client NPM packages updaten
echo 'update AudioClient npm packages'
cd C:/Apache24/htdocs/MortenHe/AudioClient 
npm update
echo

#SH Audio Client NPM packages updaten
echo 'update NewSHAudioClient npm packages'
cd C:/Apache24/htdocs/MortenHe/NewSHAudioClient
npm update
echo

#Video Client NPM packages updaten
echo 'update VideoClient npm packages'
cd C:/Apache24/htdocs/MortenHe/VideoClient
npm update
echo

#keep windows opened
echo 'update done'
$SHELL