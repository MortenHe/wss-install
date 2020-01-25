#!/bin/sh

echo 'set static ip address in router settings'
echo '192.168.0.1'

echo 'update / dist-upgrade system'
sudo apt-get update && sudo apt-get -y dist-upgrade
echo

#read values from config file
. ./config

#check if default root pw from config file was changed
if [ $ROOTPW = "CHANGEME" ];
then
  echo 'please change root pw in config file'
  exit 1;
fi

echo 'set root pw'
sudo sh -c "echo root:$ROOTPW | chpasswd"
echo

echo 'enable ssh root login'
sed 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' -i /etc/ssh/sshd_config
/etc/init.d/ssh restart
echo

echo 'set aliases in /root/.bashrc'
sed "$ a alias ..='cd ..'" -i /root/.bashrc
sed "$ a alias startnode='/home/pi/mh_prog/AudioServer/startnode.sh'" -i /root/.bashrc
sed "$ a alias startnodesh='/home/pi/mh_prog/NewSHAudioServer/startnodesh.sh'" -i /root/.bashrc
sed "$ a alias startnodesound='/home/pi/mh_prog/SoundQuizServer/startnodesound.sh'" -i /root/.bashrc
sed "$ a alias stopnode='/home/pi/mh_prog/AudioServer/stopnode.sh'" -i /root/.bashrc
sed "$ a alias pullgit='sudo /home/pi/wss-install/pull-git-audio-repos.sh'" -i /root/.bashrc
sed "$ a alias npmupdate='sudo /home/pi/wss-install/update-audio-npm-packages.sh'" -i /root/.bashrc
sed "$ a alias update='sudo apt-get update && sudo apt-get -y dist-upgrade && pullgit && npmupdate'" -i /root/.bashrc
source /root/.bashrc
echo

echo 'set cmdline output to quiet'
sed 's/$/ quiet/' -i /boot/cmdline.txt
echo

echo 'set wss player autostart in rc.local'
sed '$ i\/home/pi/wss-install/start-last-wss-player.sh &' -i /etc/rc.local
cp /home/pi/wss-install/last-player.dist /home/pi/wss-install/last-player
chmod 777 /home/pi/wss-install/last-player
echo

echo 'install nodejs'
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
echo

echo 'install mplayer'
sudo apt-get install -y mplayer 
echo

echo 'set git config'
git config --global user.email "martin-helfer@gmx.de"
git config --global user.name "Martin Helfer"
echo

echo 'get audio wss code from github'
mkdir -p /home/pi/mh_prog
git clone https://github.com/MortenHe/AudioServer /home/pi/mh_prog/AudioServer
echo

echo 'install audio wss server' 
npm --prefix /home/pi/mh_prog/AudioServer install
cp /home/pi/mh_prog/AudioServer/config.json.dist /home/pi/mh_prog/AudioServer/config.json
echo

echo 'get sh audio wss code from github'
git clone https://github.com/MortenHe/NewSHAudioServer /home/pi/mh_prog/NewSHAudioServer
echo

echo 'install sh audio wss server' 
npm --prefix /home/pi/mh_prog/NewSHAudioServer install
cp /home/pi/mh_prog/NewSHAudioServer/config.json.dist /home/pi/mh_prog/NewSHAudioServer/config.json
echo

echo 'get soundquiz wss code from github' 
git clone https://github.com/MortenHe/SoundQuizServer /home/pi/mh_prog/SoundQuizServer
echo 

echo 'install soundquiz wss server'
npm --prefix /home/pi/mh_prog/SoundQuizServer install
cp /home/pi/mh_prog/SoundQuizServer/config.json.dist /home/pi/mh_prog/SoundQuizServer/config.json

echo 'install apache'
sudo apt-get install -y apache2
sudo a2enmod rewrite
echo

echo 'update apache config'
sed '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' -i /etc/apache2/apache2.conf
systemctl restart apache2
echo

echo 'install php'
sudo apt-get install -y php libapache2-mod-php
sed '$ i\%www-data ALL=NOPASSWD: ALL' -i /etc/sudoers
echo

echo 'deploy php activate script'
mkdir /var/www/html/php
cp /home/pi/wss-install/activateAudioApp.php /var/www/html/php/
echo

echo 'prepare usb automount mount'
sudo apt-get install -y ntfs-3g
sudo mkdir /media/usb_audio
echo

#GPIO Buttons
if [ $GPIOBUTTONS = true ];
then
  echo 'get gpio buttons code from github'
  git clone https://github.com/MortenHe/WSGpioButtons /home/pi/mh_prog/WSGpioButtons
  echo

  echo 'install gpio buttons' 
  sudo npm --prefix /home/pi/mh_prog/WSGpioButtons install
  cp /home/pi/mh_prog/WSGpioButtons/config.json.dist /home/pi/mh_prog/WSGpioButtons/config.json
  echo

  echo 'enable gpio buttons in audio and sh audio server'
  sed 's/"GPIOButtons": false/"GPIOButtons": true/' -i /home/pi/mh_prog/AudioServer/config.json
  sed 's/"GPIOButtons": false/"GPIOButtons": true/' -i /home/pi/mh_prog/NewSHAudioServer/config.json
fi

#USB RFID Reader
if [ $USBRFIDREADER = true ];
then
  echo 'get usb rfid reader code from github'
  git clone https://github.com/MortenHe/WSRFID /home/pi/mh_prog/WSRFID
  echo

  echo 'install usb rfid reader' 
  npm --prefix /home/pi/mh_prog/WSRFID install
  cp /home/pi/mh_prog/WSRFID/config_input.json.dist /home/pi/mh_prog/WSRFID/config_input.json
  echo

  echo 'enable usb rfid reader in audio and sh audio server'
  sed 's/"USBRFIDReader": false/"USBRFIDReader": true/' -i /home/pi/mh_prog/AudioServer/config.json
  sed 's/"USBRFIDReader": false/"USBRFIDReader": true/' -i /home/pi/mh_prog/NewSHAudioServer/config.json
fi

echo 'get and install mausberry power button script'
sudo wget http://files.mausberrycircuits.com/setup.sh
sudo bash setup.sh

#Hifiberry Audio Card
if  [ $HIFIBERRY = true ];
then
  echo 'set hifiberry audio card'
  sed 's/dtparam=audio=on/dtoverlay=hifiberry-dacplus/' -i /boot/config.txt
  echo
fi  

echo 'optimize startup time in /boot/config.txt'
echo "# Disable the rainbow splash screen" >> /boot/config.txt
echo "disable_splash=1" >> /boot/config.txt

echo "# Disable bluetooth" >> /boot/config.txt
echo "dtoverlay=pi3-disable-bt" >> /boot/config.txt

echo "# Overclock the SD Card from 50 to 100MHz" >> /boot/config.txt
echo "# This can only be done with at least a UHS Class 1 card" >> /boot/config.txt
echo "dtoverlay=sdtweak,overclock_50=100" >> /boot/config.txt
 
echo "# Set the bootloader delay to 0 seconds. The default is 1s if not specified." >> /boot/config.txt
echo "boot_delay=0" >> /boot/config.txt

echo "# Overclock the raspberry pi. This voids its warranty. Make sure you have a good power supply." >> /boot/config.txt
echo "force_turbo=1" >> /boot/config.txt

echo "disable unused services"
sudo systemctl disable raspi-config.service
sudo systemctl disable keyboard-setup.service
sudo systemctl disable dphys-swapfile.service
sudo systemctl disable avahi-daemon.service
sudo systemctl disable triggerhappy.service

echo 'installation done'
echo 'please reboot pi and read 02-after-installation.txt'