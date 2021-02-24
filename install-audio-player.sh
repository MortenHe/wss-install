#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROG_DIR="${DIR}/..";
echo ${PROG_DIR}

exit

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
sed "$ a alias startnode='${PROG_DIR}/AudioServer/startnode.sh'" -i /root/.bashrc
sed "$ a alias startnodesh='${PROG_DIR}/AudioServer/startnodesh.sh'" -i /root/.bashrc
sed "$ a alias startnodesound='${PROG_DIR}/AudioServer/startnodesound.sh'" -i /root/.bashrc
sed "$ a alias startnodesoundplayer='${PROG_DIR}/AudioServer/startnodesoundplayer.sh'" -i /root/.bashrc
sed "$ a alias stopnode='${PROG_DIR}/AudioServer/stopnode.sh'" -i /root/.bashrc
sed "$ a alias pullgit='${PROG_DIR}/wss-install/pull-git-audio-repos.sh'" -i /root/.bashrc
sed "$ a alias npmupdate='${PROG_DIR}/wss-install/update-audio-npm-packages.sh'" -i /root/.bashrc
sed "$ a alias update='apt-get update && apt-get -y dist-upgrade && apt-get -y autoremove && apt-get -y autoclean && pullgit && npmupdate'" -i /root/.bashrc
sed "$ a alias tailf='tail -f ${PROG_DIR}/output-server.txt'" -i /root/.bashrc
source /root/.bashrc
echo

echo 'set cmdline output to quiet'
sed 's/$/ quiet/' -i /boot/cmdline.txt
echo

echo 'set wss player autostart in rc.local'
sed '$ i\${PROG_DIR}/wss-install/start-last-wss-player.sh &' -i /etc/rc.local
cp ${PROG_DIR}/wss-install/last-player.dist /home/pi/wss-install/last-player
chmod 777 ${PROG_DIR}/wss-install/last-player
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

echo 'get and install AUDIO wss code from github'
git clone https://github.com/MortenHe/AudioServer ${PROG_DIR}/AudioServer
npm --prefix ${PROG_DIR}/AudioServer install
cp ${PROG_DIR}/AudioServer/config.json.dist ${PROG_DIR}/AudioServer/config.json
echo

echo 'get and install SH AUDIO wss code from github'
git clone https://github.com/MortenHe/NewSHAudioServer ${PROG_DIR}/NewSHAudioServer
npm --prefix ${PROG_DIR}/NewSHAudioServer install
echo

echo 'get and install SOUNDQUIZ wss code from github' 
git clone https://github.com/MortenHe/SoundQuizServer ${PROG_DIR}/SoundQuizServer
npm --prefix ${PROG_DIR}/SoundQuizServer install

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
  echo 'get and install GPIO BUTTONS code from github'
  git clone https://github.com/MortenHe/WSGpioButtons ${PROG_DIR}/WSGpioButtons
  npm --prefix ${PROG_DIR}/WSGpioButtons install
  cp ${PROG_DIR}/WSGpioButtons/config_7070.json.dist ${PROG_DIR}/WSGpioButtons/config_7070.json
  cp ${PROG_DIR}/WSGpioButtons/config_8080.json.dist ${PROG_DIR}/WSGpioButtons/config_8080.json
  cp ${PROG_DIR}/WSGpioButtons/config_9090.json.dist ${PROG_DIR}/WSGpioButtons/config_9090.json
  echo

  echo 'enable GPIO BUTTONS in AUDIO CONFIG'
  sed 's/"GPIOButtons": false/"GPIOButtons": true/' -i ${PROG_DIR}/AudioServer/config.json
fi

#USB RFID Reader
if [ $USBRFIDREADER = true ];
then
  echo 'get and install USB RFID READER code from github'
  git clone https://github.com/MortenHe/WSRFID ${PROG_DIR}/WSRFID
  npm --prefix ${PROG_DIR}/WSRFID install
  echo

  echo 'enable USB RFID READER in AUDIO CONFIG'
  sed 's/"USBRFIDReader": false/"USBRFIDReader": true/' -i ${PROG_DIR}/AudioServer/config.json
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