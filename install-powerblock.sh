#!/bin/bash

echo 'get and install POWERBLOCK power button script'
cd ..
wget -O - https://raw.githubusercontent.com/petrockblog/PowerBlock/master/install.sh | sudo bash

echo 'edit config shutdownpin 18 -> 14'
echo 'nano /etc/powerblockconfig.cfg'