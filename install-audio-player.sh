#!/bin/sh

### Woher Skript laden
### Set config.json?
### IP extern DHCP setzen
### WLAN power_off deaktiveren?
### USB Stick config?
### Webseite auf Server bauen und deployen?
### alsamixer | aplay -l für Info zu audioOutput

echo 'update / upgrade system'
sudo apt-get update && sudo apt-get -y dist-upgrade && sudo apt-get -y upgrade

echo 'set root pw'
sudo sh -c 'echo root:martin12 | chpasswd'

echo 'enable ssh root login'
sed 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' -i /etc/ssh/sshd_config
/etc/init.d/ssh restart

echo 'set aliases in .bashrc'
sed -e "\$aalias ..='cd ..'\nalias update='sudo apt-get update && sudo apt-get -y dist-upgrade && sudo apt-get -y upgrade'\nalias startnode='/home/pi/mh_prog/AudioServer/startnode.sh'\nalias stopnode='/home/pi/mh_prog/AudioServer/stopnode.sh'\n" -i /root/.bashrc
source /root/.bashrc

echo 'set wss autostart in rc.local'
sed '$ i\/home/pi/mh_prog/AudioServer/startnode.sh &' -i /etc/rc.local

echo 'install nodejs'
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs

echo 'install mplayer'
sudo apt-get install -y mplayer 

echo 'set git config'
git config --global user.email "martin-helfer@gmx.de"
git config --global user.name "Martin Helfer"

echo 'get audio wss code from github'
mkdir -p /home/pi/mh_prog
git clone https://github.com/MortenHe/AudioServer /home/pi/mh_prog/AudioServer

echo 'install audio wss server' 
npm  --prefix /home/pi/mh_prog/AudioServer install
cp /home/pi/mh_prog/AudioServer/config.json.dist /home/pi/mh_prog/AudioServer/config.json

echo 'get sh audio wss code from github'
git clone https://github.com/MortenHe/NewSHAudioServer /home/pi/mh_prog/NewSHAudioServer

echo 'install sh audio wss server' 
npm  --prefix /home/pi/mh_prog/NewSHAudioServer install
cp /home/pi/mh_prog/NewSHAudioServer/config.json.dist /home/pi/mh_prog/NewSHAudioServer/config.json

echo 'install apache'
sudo apt-get install -y apache2
sudo a2enmod rewrite

echo 'update apache config'
sed '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' -i /etc/apache2/apache2.conf
systemctl restart apache2

echo 'install php'
sudo apt-get install -y php libapache2-mod-php
sed '$ i\%www-data ALL=NOPASSWD: ALL' -i /etc/sudoers

echo 'deploy php activate script'
mkdir /var/www/html/php
cp /home/pi/mh_prog/AudioServer/activateApp.php /var/www/html/php/

echo 'prepare usb mount'
sudo apt-get install -y ntfs-3g
sudo mkdir /media/usb_audio