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

#https://crycode.de/nextcloud-client-auf-dem-raspberry-pi
# Fuer Installtion mit Raspberry OS Lite
sudo apt update
sudo apt -y install build-essential git cmake openssl libssl-dev sqlite3 libsqlite3-dev qt5-default libqt5webkit5-dev qttools5-dev qttools5-dev-tools python-sphinx texlive-latex-base inotify-tools qt5keychain-dev doxygen extra-cmake-modules kio-dev

#compile nextcloud client
cd ~
git clone https://github.com/nextcloud/client_theming.git nextcloud_client
cd nextcloud_client
git submodule update --init
cd client
git submodule update --init
cd ..
mkdir build
cd build
cmake -D OEM_THEME_DIR=$(pwd)/../nextcloudtheme ../client
sed -i 's/Icon=nextcloud/Icon=Nextcloud/g' src/gui/nextcloud.desktop
sed -i 's/Icon\[\(.*\)\]=nextcloud/Icon\[\1\]=Nextcloud/g' src/gui/nextcloud.desktop
make

#install nextcloud client
sudo make install

echo 'LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/arm-linux-gnueabihf' | sudo tee -a /etc/environment
grep '/usr/local/lib/arm-linux-gnueabihf' /etc/ld.so.conf.d/arm-linux-gnueabihf.conf >/dev/null 2>&1 || echo '/usr/local/lib/arm-linux-gnueabihf' | sudo tee -a /etc/ld.so.conf.d/arm-linux-gnueabihf.conf
grep '/usr/local/lib/arm-linux-gnueabihf' /etc/ld.so.conf.d/x86_64-linux-gnu.conf >/dev/null 2>&1 || echo '/usr/local/lib/arm-linux-gnueabihf' | sudo tee -a /etc/ld.so.conf.d/x86_64-linux-gnu.conf
sudo ldconfig
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/arm-linux-gnueabihf

echo "EDIT FILES:"
echo "nano ${DIR}/nextcloud-sync.sh"
echo "nano ~/.netrc"
echo "crontab -e"