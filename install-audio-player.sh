#!/bin/sh

### TODO ###
### Woher Skript laden ###
### Set config.json? ###
### NPM installieren? ###
### WLAN power_off deaktiveren? ###
### set git config ? ###
### USB Stick config? ###
### Webseite auf Server bauen und deployed? ###

echo 'set root pw'
sudo sh -c 'echo root:martin12 | chpasswd'

echo 'enable ssh root login'
sed 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' -i /etc/ssh/sshd_config
#sed 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /sed-test/sshd_config
/etc/init.d/ssh restart

echo 'set aliases in .bashrc'
sed -e "\$aalias ..='cd ..'\nalias update='sudo apt-get update && sudo apt-get upgrade'\nalias startnode='/home/pi/mh_prog/AudioServer/startnode.sh'\nalias stopnode='/home/pi/mh_prog/AudioServer/stopnode.sh'\n" -i /root/.bashrc
#sed -e "\$aalias ..='cd ..'\nalias update='sudo apt-get update && sudo apt-get upgrade'\nalias startnode='/home/pi/mh_prog/AudioServer/startnode.sh'\nalias stopnode='/home/pi/mh_prog/AudioServer/stopnode.sh'\n" /sed-test/.bashrc
source /root/.bashrc

echo 'set wss autostart in rc.local'
sed '$ i\/home/pi/mh_prog/AudioServer/startnode.sh &' -i /etc/rc.local
#sed '$ i\/home/pi/mh_prog/AudioServer/startnode.sh &' /sed-test/rc.local

echo 'install nodejs'
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs

echo 'install mplayer'
sudo apt-get install -y mplayer 

echo 'get wss code from github'
mkdir -p /home/pi/mh_prog
git clone https://github.com/MortenHe/AudioServer /home/pi/mh_prog/AudioServer

echo 'install wss server' 
npm  --prefix /home/pi/mh_prog/AudioServer install
cp /home/pi/mh_prog/AudioServer/config.json.dist /home/pi/mh_prog/AudioServer/config.json

echo 'install apache'
sudo apt-get install -y apache2
sudo a2enmod rewrite

echo 'update apache config'
sed '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' -i /etc/apache2/apache2.conf
#sed '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /sed-test/apache2.conf
systemctl restart apache2

echo 'install php'
sudo apt-get install -y php libapache2-mod-php
sed '$ i\%www-data ALL=NOPASSWD: ALL' -i /etc/sudoers
sed '$ i\%www-data ALL=NOPASSWD: ALL' /sed-test/sudoers

echo 'deploy php activate script'
mkdir /var/www/html/php
cp /home/pi/mh_prog/AudioServer/activateApp.php /var/www/html/php/