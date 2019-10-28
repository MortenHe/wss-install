#!/bin/sh

echo 'set static ip address in router settings'
echo '192.168.0.1'

echo 'update / upgrade system'
sudo apt-get update && sudo apt-get -y dist-upgrade && sudo apt-get -y upgrade
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

echo 'set aliases in .bashrc'
sed -e "\$aalias ..='cd ..'\nalias update='sudo apt-get update && sudo apt-get -y dist-upgrade && sudo apt-get -y upgrade'\nalias startnode='/home/pi/mh_prog/AudioServer/startnode.sh'\nalias startnodesh='/home/pi/mh_prog/NewSHAudioServer/startnodesh.sh'\nalias startnodesound='/home/pi/mh_prog/SoundQuizServer/startnodesound.sh'\nalias stopnode='/home/pi/mh_prog/AudioServer/stopnode.sh'\n" -i /root/.bashrc
source /root/.bashrc
echo

echo 'set audio wss autostart in rc.local'
sed '$ i\/home/pi/mh_prog/AudioServer/startnode.sh &' -i /etc/rc.local
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
npm  --prefix /home/pi/mh_prog/AudioServer install
cp /home/pi/mh_prog/AudioServer/config.json.dist /home/pi/mh_prog/AudioServer/config.json
echo

echo 'get sh audio wss code from github'
git clone https://github.com/MortenHe/NewSHAudioServer /home/pi/mh_prog/NewSHAudioServer
echo

echo 'install sh audio wss server' 
npm  --prefix /home/pi/mh_prog/NewSHAudioServer install
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
cp /home/pi/mh_prog/AudioServer/activateApp.php /var/www/html/php/
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
  sudo npm  --prefix /home/pi/mh_prog/WSGpioButtons install
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
  npm  --prefix /home/pi/mh_prog/WSRFID install
  cp /home/pi/mh_prog/WSRFID/config_input.json.dist /home/pi/mh_prog/WSRFID/config_input.json
  echo

  echo 'enable usb rfid reader in audio and sh audio server'
  sed 's/"USBRFIDReader": false/"USBRFIDReader": true/' -i /home/pi/mh_prog/AudioServer/config.json
  sed 's/"USBRFIDReader": false/"USBRFIDReader": true/' -i /home/pi/mh_prog/NewSHAudioServer/config.json
fi

echo 'get and install mausberry power button script'
sudo wget http://files.mausberrycircuits.com/setup.sh
sudo bash setup.sh

echo 'installation done'
echo 'read 02-after-installation.txt'