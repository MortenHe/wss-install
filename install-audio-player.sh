#!/bin/sh

### Config.json fuer rootPW vs. interaktiv, 
### GPIO-Buttons, RFID-USB aktivieren ueber Audioserver config
### startnode audio shaudio
### RFID shplayer
### gemeinsame Tasks von Audion und Video in gemeinsames Bash auslagern und nur spezielle Anweisungen
### IP extern DHCP setzen
### WLAN power_off deaktiveren?
### USB Stick config?
### Mausberry
### Webseite auf Server bauen und deployen?
### useradd -m pi?

echo 'update / upgrade system'
sudo apt-get update && sudo apt-get -y dist-upgrade && sudo apt-get -y upgrade
echo

echo 'set root pw'
sudo sh -c 'echo root:martin12 | chpasswd'
echo

echo 'enable ssh root login'
sed 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' -i /etc/ssh/sshd_config
/etc/init.d/ssh restart
echo

echo 'set aliases in .bashrc'
sed -e "\$aalias ..='cd ..'\nalias update='sudo apt-get update && sudo apt-get -y dist-upgrade && sudo apt-get -y upgrade'\nalias startnode='/home/pi/mh_prog/AudioServer/startnode.sh'\nalias stopnode='/home/pi/mh_prog/AudioServer/stopnode.sh'\n" -i /root/.bashrc
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

echo 'prepare usb mount'
sudo apt-get install -y ntfs-3g
sudo mkdir /media/usb_audio
echo

echo 'get gpio buttons code from github'
git clone https://github.com/MortenHe/WSGpioButtons /home/pi/mh_prog/WSGpioButtons
echo

echo 'install gpio buttons' 
npm  --prefix /home/pi/mh_prog/WSGpioButtons install
cp /home/pi/mh_prog/WSGpioButtons/config.json.dist /home/pi/mh_prog/WSGpioButtons/config.json
echo

echo 'get usb rfid reader code from github'
git clone https://github.com/MortenHe/WSRFID /home/pi/mh_prog/WSRFID
echo

echo 'install usb rfid reader' 
npm  --prefix /home/pi/mh_prog/WSRFID install
cp /home/pi/mh_prog/WSRFID/config_input.json.dist /home/pi/mh_prog/WSRFID/config_input.json
echo

echo 'installation done'
echo

echo 'config audio server'
echo 'alsamixer'
echo 'vi /home/pi/mh_prog/AudioServer/config.json'
echo 'vi /home/pi/mh_prog/NewSHAudioServer/config.json'
echo

echo 'config mplayer'
echo 'aplay -l'
echo 'vi /root/.mplayer/config'
echo 'ao=alsa:device=hw=1.0'

echo 'config button pins'
echo 'vi /home/pi/mh_prog/WSGpioButtons/config.json'
echo

echo 'config usb rfid reader'
echo 'cat /dev/input/event0'
echo 'vi /home/pi/mh_prog/WSRFID/config_input.json'