#!/bin/sh
# https://forum-raspberrypi.de/forum/thread/47007-tutorial-nextcloud-client-fuer-den-raspberry/
cd /home/pi
wget ftp.de.debian.org/debian/pool/main/n/nextcloud-desktop/nextcloud-desktop_2.5.1-3+deb10u1_armhf.deb
sudo apt install -y nextcloud-desktop-common nextcloud-desktop-l10n libqt5keychain1 libqt5positioning5 libqt5qml5 libqt5quick5 libqt5webchannel5 libqt5webkit5 libqt5webengine-data libminizip1 libre2-5 libqt5quickwidgets5

wget ftp.de.debian.org/debian/pool/main/n/nextcloud-desktop/libnextcloudsync0_2.5.1-3+deb10u1_armhf.deb
wget ftp.de.debian.org/debian/pool/main/q/qtwebengine-opensource-src/libqt5webenginecore5_5.11.3+dfsg-2+deb10u1_armhf.deb
wget ftp.de.debian.org/debian/pool/main/q/qtwebengine-opensource-src/libqt5webenginewidgets5_5.11.3+dfsg-2+deb10u1_armhf.deb

sudo dpkg -i libnextcloudsync0_2.5.1-3+deb10u1_armhf.deb
sudo dpkg -i libqt5webenginecore5_5.11.3+dfsg-2+deb10u1_armhf.deb
sudo dpkg -i libqt5webenginewidgets5_5.11.3+dfsg-2+deb10u1_armhf.deb

sudo dpkg -i nextcloud-desktop_2.5.1-3+deb10u1_armhf.deb 

# selbst kompilieren
#https://crycode.de/nextcloud-client-auf-dem-raspberry-pi

#sudo apt update
#sudo apt -y install build-essential git cmake openssl libssl-dev sqlite3 libsqlite3-dev qt5-default libqt5webkit5-dev qttools5-dev qttools5-dev-tools python-sphinx texlive-latex-base inotify-tools qt5keychain-dev doxygen extra-cmake-modules kio-dev

#compile nextcloud client
#cd ~
#git clone https://github.com/nextcloud/client_theming.git nextcloud_client
#cd nextcloud_client
#git submodule update --init
#cd client
#git submodule update --init
#cd ..
#mkdir build
#cd build
#cmake -D OEM_THEME_DIR=$(pwd)/../nextcloudtheme ../client
#sed -i 's/Icon=nextcloud/Icon=Nextcloud/g' src/gui/nextcloud.desktop
#sed -i 's/Icon\[\(.*\)\]=nextcloud/Icon\[\1\]=Nextcloud/g' src/gui/nextcloud.desktop
#make

#install nextcloud client
#sudo make install

#echo 'LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/arm-linux-gnueabihf' | sudo tee -a /etc/environment
#grep '/usr/local/lib/arm-linux-gnueabihf' /etc/ld.so.conf.d/arm-linux-gnueabihf.conf >/dev/null 2>&1 || echo '/usr/local/lib/arm-linux-gnueabihf' | sudo tee -a /etc/ld.so.conf.d/arm-linux-gnueabihf.conf
#grep '/usr/local/lib/arm-linux-gnueabihf' /etc/ld.so.conf.d/x86_64-linux-gnu.conf >/dev/null 2>&1 || echo '/usr/local/lib/arm-linux-gnueabihf' | sudo tee -a /etc/ld.so.conf.d/x86_64-linux-gnu.conf
#sudo ldconfig
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/arm-linux-gnueabihf

#start nextcloud client with cli command: nextcloud