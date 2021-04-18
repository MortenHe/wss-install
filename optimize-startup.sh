#!/bin/bash

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