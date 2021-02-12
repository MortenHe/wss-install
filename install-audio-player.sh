#!/bin/sh

echo 'update / dist-upgrade system'
apt-get update && apt-get -y dist-upgrade
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
sh -c "echo root:$ROOTPW | chpasswd"
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
sed "$ a alias startnodesoundplayer='/home/pi/mh_prog/SoundQuizServer/startnodesoundplayer.sh'" -i /root/.bashrc
sed "$ a alias stopnode='/home/pi/mh_prog/AudioServer/stopnode.sh'" -i /root/.bashrc
sed "$ a alias pullgit='/home/pi/wss-install/pull-git-audio-repos.sh'" -i /root/.bashrc
sed "$ a alias npmupdate='/home/pi/wss-install/update-audio-npm-packages.sh'" -i /root/.bashrc
sed "$ a alias update='apt-get update && apt-get -y dist-upgrade && apt-get -y autoremove && apt-get -y autoclean && pullgit && npmupdate'" -i /root/.bashrc
sed "$ a alias tailf='tail -f /home/pi/mh_prog/output-server.txt'" -i /root/.bashrc
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
curl -sL https://deb.nodesource.com/setup_15.x | bash -
apt-get install -y nodejs
echo

echo 'install mplayer'
apt-get install -y mplayer 
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
apt-get install -y apache2
a2enmod rewrite
echo

echo 'update apache config'
sed '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' -i /etc/apache2/apache2.conf
systemctl restart apache2
echo

echo 'install php'
apt-get install -y php libapache2-mod-php
sed '$ i\%www-data ALL=NOPASSWD: ALL' -i /etc/sudoers
echo

echo 'deploy php activate script'
mkdir /var/www/html/php
cp /home/pi/wss-install/activateAudioApp.php /var/www/html/php/
echo

#Audio liegt auf SD Karte und wird per Nextcloud gesynct, daher kein USB-Stick mehr
#echo 'prepare usb automount mount'
#apt-get install -y ntfs-3g
#mkdir /media/usb_audio
#echo

#GPIO Buttons
if [ $GPIOBUTTONS = true ];
then
  echo 'get gpio buttons code from github'
  git clone https://github.com/MortenHe/WSGpioButtons /home/pi/mh_prog/WSGpioButtons
  echo

  echo 'install gpio buttons' 
  npm --prefix /home/pi/mh_prog/WSGpioButtons install
  cp /home/pi/mh_prog/WSGpioButtons/config_7070.json.dist /home/pi/mh_prog/WSGpioButtons/config_7070.json
  cp /home/pi/mh_prog/WSGpioButtons/config_8080.json.dist /home/pi/mh_prog/WSGpioButtons/config_8080.json
  cp /home/pi/mh_prog/WSGpioButtons/config_9090.json.dist /home/pi/mh_prog/WSGpioButtons/config_9090.json
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
  cp /home/pi/mh_prog/WSRFID/config.json.dist /home/pi/mh_prog/WSRFID/config.json
  echo

  echo 'enable usb rfid reader in audio and sh audio server'
  sed 's/"USBRFIDReader": false/"USBRFIDReader": true/' -i /home/pi/mh_prog/AudioServer/config.json
  sed 's/"USBRFIDReader": false/"USBRFIDReader": true/' -i /home/pi/mh_prog/NewSHAudioServer/config.json
fi

#echo 'install nextcloud client'
#apt-get install -y nextcloud-desktop

#Hifiberry Audio Card
if  [ $HIFIBERRY = true ];
then
  echo 'set hifiberry audio card'
  sed 's/dtparam=audio=on/dtoverlay=hifiberry-dacplus/' -i /boot/config.txt
  echo
fi  

echo 'optimize startup time in /boot/config.txt'
sed "$ a # Disable the rainbow splash screen" -i /boot/config.txt
sed "$ a disable_splash=1" -i /boot/config.txt

sed "$ a # Disable bluetooth" -i /boot/config.txt
sed "$ a dtoverlay=pi3-disable-bt" -i /boot/config.txt

sed "$ a # Overclock the SD Card from 50 to 100MHz" -i /boot/config.txt
sed "$ a # This can only be done with at least a UHS Class 1 card" -i /boot/config.txt
sed "$ a dtoverlay=sdtweak,overclock_50=100" -i /boot/config.txt

sed "$ a # Set the bootloader delay to 0 seconds. The default is 1s if not specified." -i /boot/config.txt
sed "$ a boot_delay=0" -i /boot/config.txt

sed "$ a # Overclock the raspberry pi. This voids its warranty. Make sure you have a good power supply." -i /boot/config.txt
sed "$ a force_turbo=1" -i /boot/config.txt

echo "disable unused services"
systemctl disable raspi-config.service
systemctl disable keyboard-setup.service
systemctl disable dphys-swapfile.service
systemctl disable avahi-daemon.service
systemctl disable triggerhappy.service
systemctl disable apt-daily.service
systemctl disable avahi-daemon.service
systemctl disable rsyslog.service
systemctl disable rpi-eeprom-update

echo "uninstall unused software"
apt-get purge -y modemmanager
apt-get purge -y avahi-daemon

echo 'get and install mausberry power button script'
wget http://files.mausberrycircuits.com/setup.sh
bash setup.sh

echo 'installation done'
echo 'please reboot pi and read 02-after-installation.txt'