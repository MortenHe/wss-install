#!/bin/bash

#Installtion-Dir fuer Video Server ect. aus aktuellem Verzeichnis ableiten
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
sed "$ a alias startnode='${PROG_DIR}/VideoServer/startnode.sh'" -i ${BASH_FILE}
sed "$ a alias stopnode='${PROG_DIR}/VideoServer/stopnode.sh'" -i ${BASH_FILE}
sed "$ a alias tailf='tail -f ${PROG_DIR}/output-server.txt'" -i ${BASH_FILE}
sed "$ a alias pullgit='${PROG_DIR}/wss-install/pull-git-video-repos.sh'" -i ${BASH_FILE}
sed "$ a alias npmupdate='${PROG_DIR}/wss-install/update-video-npm-packages.sh'" -i ${BASH_FILE}
sed "$ a alias update='apt-get update && apt-get -y dist-upgrade && apt-get -y autoremove && apt-get -y autoclean && pullgit && npmupdate'" -i ${BASH_FILE}
sed "$ a alias mh_prog='cd ${PROG_DIR}'" -i ${BASH_FILE}
source ${BASH_FILE}
echo

echo 'install NODEJS'
curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get install -y nodejs
echo

echo 'install APACHE'
apt-get install -y apache2
a2enmod rewrite
#allow override fuer angular
sed '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' -i /etc/apache2/apache2.conf
#Nextcloud als Ort fuer Webseite
sed 's|/var/www/html|/media/pi/usb_red/Nextcloud/video/website|g' -i /etc/apache2/sites-available/000-default.conf
sed 's|/var/www/|/media/pi/usb_red/Nextcloud/video/website|g' -i /etc/apache2/apache2.conf
#.htaccess in Nextcloud-Ordner kopieren
cp ${PROG_DIR}/wss-install/.htaccess-wvp /media/pi/usb_red/Nextcloud/video/website/wvp/.htaccess
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
git config --global pull.rebase false
echo

echo 'get and install VIDEO wss code from github'
git clone https://github.com/MortenHe/VideoServer ${PROG_DIR}/VideoServer
npm --prefix ${PROG_DIR}/VideoServer install
cp ${PROG_DIR}/VideoServer/config.json.dist ${PROG_DIR}/VideoServer/config.json
echo

echo 'install CEC-UTILS'
sudo apt-get install -y cec-utils
echo

echo 'set VIDEO player AUTOSTART in rc.local'
sed "$ i\ ${PROG_DIR}/VideoServer/startnode.sh &" -i /etc/rc.local
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