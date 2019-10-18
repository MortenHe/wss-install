#!/bin/sh

### Config.json fuer rootPW vs. interaktiv
### startnode
### IP extern DHCP setzen
### WLAN power_off deaktiveren?
### USB Stick config?
### Mausberry
### Webseite auf Server bauen und deployen?

### After Installation
### edit /home/pi/mh_prog/VideoServer/config.json

echo 'update / upgrade system'
sudo apt-get update && sudo apt-get -y dist-upgrade && sudo apt-get -y upgrade

echo 'set root pw'
sudo sh -c 'echo root:martin12 | chpasswd'

echo 'enable ssh root login'
sed 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' -i /etc/ssh/sshd_config
/etc/init.d/ssh restart

echo 'set aliases in .bashrc'
sed -e "\$aalias ..='cd ..'\nalias update='sudo apt-get update && sudo apt-get -y dist-upgrade && sudo apt-get -y upgrade'\nalias startnode='/home/pi/mh_prog/VideoServer/startnode.sh'\nalias stopnode='/home/pi/mh_prog/VideoServer/stopnode.sh'\n" -i /root/.bashrc
source /root/.bashrc

echo 'set video wss autostart in rc.local'
sed '$ i\/home/pi/mh_prog/VideoServer/startnode.sh &' -i /etc/rc.local

echo 'install nodejs'
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs

echo 'set git config'
git config --global user.email "martin-helfer@gmx.de"
git config --global user.name "Martin Helfer"

echo 'get video wss code from github'
mkdir -p /home/pi/mh_prog
git clone https://github.com/MortenHe/VideoServer /home/pi/mh_prog/VideoServer

echo 'install video wss server' 
npm  --prefix /home/pi/mh_prog/VideoServer install
cp /home/pi/mh_prog/VideoServer/config.json.dist /home/pi/mh_prog/VideoServer/config.json

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
cp /home/pi/mh_prog/VideoServer/activateApp.php /var/www/html/php/

echo 'install cec-utils'
sudo apt-get install -y cec-utils