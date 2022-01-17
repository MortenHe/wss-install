#!/bin/bash
#Script dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#Make Nextcloud dir'
mkdir ${DIR}/../../Nextcloud

#Create .netrc file
cp ${DIR}/.netrc ~/.netrc

#Create sync-Skript
cp ${DIR}/nextcloud-sync.sh.dist ${DIR}/nextcloud-sync.sh

#Create Nextcloud sync Cronjob (need to uncomment later)
(crontab -l ; echo "# * * * * * ${DIR}/nextcloud-sync.sh >/dev/null &") | crontab -

#Create log file for sync script
touch /var/log/cloud-sync.log
chown pi:pi /var/log/cloud-sync.log

#https://crycode.de/nextcloud-client-auf-dem-raspberry-pi
wget http://ftp.de.debian.org/debian/pool/main/n/nextcloud-desktop/libnextcloudsync0_3.1.1-2+deb11u1_armhf.deb
sudo dpkg -i libnextcloudsync0_3.1.1-2+deb11u1_armhf.deb
sudo apt install -y --fix-broken

wget http://ftp.de.debian.org/debian/pool/main/n/nextcloud-desktop/nextcloud-desktop-cmd_3.1.1-2+deb11u1_armhf.deb
sudo dpkg -i nextcloud-desktop-cmd_3.1.1-2+deb11u1_armhf.deb
sudo apt install -y --fix-broken

echo "EDIT FILES:"
echo "nano ${DIR}/nextcloud-sync.sh"
echo "nano ~/.netrc"
echo "crontab -e"