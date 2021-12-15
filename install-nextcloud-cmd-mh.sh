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
apt-get install -y cmake g++ openssl libssl-dev libzip-dev qtbase5-private-dev qtdeclarative5-dev  qt5keychain-dev qttools5-dev sqlite3 libsqlite3-dev libqt5svg5-dev zlib1g-dev libqt5websockets5-dev qtquickcontrols2-5-dev shared-mime-info inksacpe
cd ~
git clone https://github.com/nextcloud/desktop.git
cd desktop
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=~/nextcloud-desktop-client -DCMAKE_BUILD_TYPE=Debug
make install

#Skript wird gestartet mit /root/desktop/build/bin/nextcloudcmd

echo "EDIT FILES:"
echo "nano ${DIR}/nextcloud-sync.sh"
echo "nano ~/.netrc"
echo "crontab -e"