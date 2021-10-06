#!/bin/bash

#Installtion-Dir fuer Audio Server ect. aus aktuellem Verzeichnis ableiten
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROG_DIR="${DIR}/..";

echo 'UPDATE / dist-upgrade system'
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

echo 'set ROOT PW'
sh -c "echo root:$ROOTPW | chpasswd"
echo

echo 'enable SSH ROOT LOGIN'
sed 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' -i /etc/ssh/sshd_config
/etc/init.d/ssh restart
echo

echo 'set ALIASES in .bashrc'
BASH_FILE=/root/.bashrc
sed "$ a alias ..='cd ..'" -i ${BASH_FILE}
sed "$ a alias startnode='${PROG_DIR}/AudioServer/startnode.sh'" -i ${BASH_FILE}
sed "$ a alias startnodesh='${PROG_DIR}/AudioServer/startnodesh.sh'" -i ${BASH_FILE}
sed "$ a alias startnodesound='${PROG_DIR}/AudioServer/startnodesound.sh'" -i ${BASH_FILE}
sed "$ a alias startnodesoundplayer='${PROG_DIR}/AudioServer/startnodesoundplayer.sh'" -i ${BASH_FILE}
sed "$ a alias stopnode='${PROG_DIR}/AudioServer/stopnode.sh'" -i ${BASH_FILE}
sed "$ a alias tailf='tail -f ${PROG_DIR}/output-server.txt'" -i ${BASH_FILE}
sed "$ a alias pullgit='${PROG_DIR}/wss-install/pull-git-audio-repos.sh'" -i ${BASH_FILE}
sed "$ a alias npmupdate='${PROG_DIR}/wss-install/update-audio-npm-packages.sh'" -i ${BASH_FILE}
sed "$ a alias update='apt-get update && apt-get -y dist-upgrade && apt-get -y autoremove && apt-get -y autoclean && pullgit && npmupdate'" -i ${BASH_FILE}
sed "$ a alias mh_prog='cd ${PROG_DIR}'" -i ${BASH_FILE}
source ${BASH_FILE}
echo

echo 'install NODEJS'
curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get install -y nodejs
echo

echo 'install MPLAYER and update CONFIG'
apt-get install -y mplayer
sed 's/ao=pulse,alsa,/ao=alsa,/' -i /etc/mplayer/mplayer.conf
echo

echo 'install APACHE'
apt-get install -y apache2
a2enmod rewrite
#allow override fuer angular
sed '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' -i /etc/apache2/apache2.conf
#Nextcloud als Ort fuer Webseite
sed 's|/var/www/html|/home/pi/Nextcloud/audio/website|g' -i /etc/apache2/sites-available/000-default.conf
sed 's|/var/www/|/home/pi/Nextcloud/audio/website|g' -i /etc/apache2/apache2.conf
#.htaccess in Nextcloud-Ordner kopieren
cp ${PROG_DIR}/wss-install/.htaccess-wap /home/pi/Nextcloud/audio/website/wap/.htaccess
systemctl restart apache2
echo

echo 'set STATIC IP ADDRESS'
DHCP_FILE=/etc/dhcpcd.conf
sed "$ a interface wlan0" -i ${DHCP_FILE}
sed "$ a static ip_address=192.168.0.${IP_ADDRESS_SUFFIX}/24" -i ${DHCP_FILE}
sed "$ a static routers=192.168.0.1" -i ${DHCP_FILE}
sed "$ a static domain_name_servers=192.168.0.1" -i ${DHCP_FILE}
echo

echo 'install PHP'
apt-get install -y php libapache2-mod-php
sed '$ i\%www-data ALL=NOPASSWD: ALL' -i /etc/sudoers
echo

echo 'set GIT CONFIG'
git config --global user.email "martin.helfer@posteo.de"
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
  echo
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
  echo
fi

#STT (Speech to Text)
if [ $STT = true ];
then
  echo 'install FFMPEG'
  apt-get install -y ffmpeg
  echo

  echo 'install PYTHON PIP'
  apt-get install -y python3-pip
  echo

  echo 'install PTYHON VOSK'
  pip3 install vosk
  echo

  echo 'get and install TTS from github'
  git clone https://github.com/alphacep/vosk-api ${PROG_DIR}/vosk-api
  wget https://alphacephei.com/vosk/models/vosk-model-small-de-0.15.zip -P ${PROG_DIR}
  unzip ${PROG_DIR}/vosk-model-small-de-0.15.zip -d ${PROG_DIR}
  mv ${PROG_DIR}/vosk-model-small-de-0.15 ${PROG_DIR}/vosk-api/python/example/model
  cp ${PROG_DIR}/wss-install/stt-mh.py ${PROG_DIR}/vosk-api/python/example
  echo

  echo 'get and install WSS TTS code from github'
  git clone https://github.com/MortenHe/WSSTT ${PROG_DIR}/WSSTT
  npm --prefix ${PROG_DIR}/WSSTT install
  echo

  echo 'get and install STT pico2wave'
  wget http://ftp.us.debian.org/debian/pool/non-free/s/svox/libttspico0_1.0+git20130326-9_armhf.deb -P ${PROG_DIR}
  wget http://ftp.us.debian.org/debian/pool/non-free/s/svox/libttspico-utils_1.0+git20130326-9_armhf.deb -P ${PROG_DIR}
  apt-get install -f -y ${PROG_DIR}/libttspico0_1.0+git20130326-9_armhf.deb ${PROG_DIR}/libttspico-utils_1.0+git20130326-9_armhf.deb
  echo

  echo 'enable USB TTS in AUDIO CONFIG'
  sed 's/"STT": false/"STT": true/' -i ${PROG_DIR}/AudioServer/config.json
  echo
fi

echo 'set AUDIO player AUTOSTART in rc.local'
sed "$ i\ ${PROG_DIR}/wss-install/start-last-wss-player.sh &" -i /etc/rc.local
cp ${PROG_DIR}/wss-install/last-player.dist ${PROG_DIR}/wss-install/last-player
chmod 777 ${PROG_DIR}/wss-install/last-player
echo

echo 'set CMDLINE output to QUIET'
sed 's/$/ quiet/' -i /boot/cmdline.txt
echo

echo 'OPTIMIZE STARTUP time in /boot/config.txt'
BOOT_CONFIG_FILE=/boot/config.txt
sed "$ a # Disable the rainbow splash screen" -i ${BOOT_CONFIG_FILE}
sed "$ a disable_splash=1" -i ${BOOT_CONFIG_FILE}

sed "$ a # Disable bluetooth" -i ${BOOT_CONFIG_FILE}
sed "$ a dtoverlay=pi3-disable-bt" -i ${BOOT_CONFIG_FILE}

sed "$ a # Overclock the SD Card from 50 to 100MHz" -i ${BOOT_CONFIG_FILE}
sed "$ a # This can only be done with at least a UHS Class 1 card" -i ${BOOT_CONFIG_FILE}
sed "$ a dtoverlay=sdtweak,overclock_50=100" -i ${BOOT_CONFIG_FILE}

sed "$ a # Set the bootloader delay to 0 seconds. The default is 1s if not specified." -i ${BOOT_CONFIG_FILE}
sed "$ a boot_delay=0" -i ${BOOT_CONFIG_FILE}

sed "$ a # Overclock the raspberry pi. This voids its warranty. Make sure you have a good power supply." -i ${BOOT_CONFIG_FILE}
sed "$ a force_turbo=1" -i ${BOOT_CONFIG_FILE}
echo

echo "disable UNUSED SERVICES"
systemctl disable raspi-config.service
systemctl disable keyboard-setup.service
systemctl disable dphys-swapfile.service
systemctl disable avahi-daemon.service
systemctl disable triggerhappy.service
systemctl disable apt-daily.service
systemctl disable avahi-daemon.service
systemctl disable rsyslog.service
systemctl disable rpi-eeprom-update
echo

echo "uninstall UNUSED SOFTWARE"
apt-get purge -y modemmanager
apt-get purge -y avahi-daemon
echo

echo 'OK'