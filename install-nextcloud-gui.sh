#!/bin/bash
# https://forum-raspberrypi.de/forum/thread/47007-tutorial-nextcloud-client-fuer-den-raspberry/
# Fuer Installtion mit Raspberry OS Desktop (geht nicht mit Lite wegen qt5)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROG_DIR="${DIR}/..";
cd ${PROG_DIR}
wget ftp.de.debian.org/debian/pool/main/n/nextcloud-desktop/nextcloud-desktop_2.5.1-3+deb10u1_armhf.deb
sudo apt install -y nextcloud-desktop-common nextcloud-desktop-l10n libqt5keychain1 libqt5positioning5 libqt5qml5 libqt5quick5 libqt5webchannel5 libqt5webkit5 libqt5webengine-data libminizip1 libre2-5 libqt5quickwidgets5

wget ftp.de.debian.org/debian/pool/main/n/nextcloud-desktop/libnextcloudsync0_2.5.1-3+deb10u1_armhf.deb
wget ftp.de.debian.org/debian/pool/main/q/qtwebengine-opensource-src/libqt5webenginecore5_5.11.3+dfsg-2+deb10u1_armhf.deb
wget ftp.de.debian.org/debian/pool/main/q/qtwebengine-opensource-src/libqt5webenginewidgets5_5.11.3+dfsg-2+deb10u1_armhf.deb

sudo dpkg -i libnextcloudsync0_2.5.1-3+deb10u1_armhf.deb
sudo dpkg -i libqt5webenginecore5_5.11.3+dfsg-2+deb10u1_armhf.deb
sudo dpkg -i libqt5webenginewidgets5_5.11.3+dfsg-2+deb10u1_armhf.deb

sudo dpkg -i nextcloud-desktop_2.5.1-3+deb10u1_armhf.deb