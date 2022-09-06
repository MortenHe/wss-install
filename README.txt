=== Audio / Video Player ===
Raspberry Pi Imager -> Raspian Lite (Raspian Buster Desktop für Video Player, weil ab Bullseye kein OMXPlayer mehr)

SSH, PW und WLAN per Pi Imager setzen

NO (Datei "ssh" in SD-boot Verzeichnis)
NO (Datei "wpa_supplicant.conf" in SD-boot Verzeichnis und anpassen)

Über ifconfig oder Router http://192.168.0.1/ IP-Adresse des Pi ermitteln

=== Installation auf Kommandozeile ===
ssh pi@192.168.0.92
(pi / raspberry (z = y) falls nicht schon eigenes PW über Pi Imager gesetzt)

sudo -s
raspi-config

1
NO (S1 WLAN)
NO (S3 change user pi password : XXX)
S6 Don't wait for network (No)

3
NO (P2 SSH)

5
NO (L1 de_DE utf-8)
NO (L2 Europe -> Berlin)
NO (L3 Generic 105 - Other - German - German - Default - Default)

=== WSS install ===
NO (apt-get install -y git)

mkdir mh_prog
cd mh_prog

git clone https://github.com/MortenHe/wss-install
cd wss-install
cp config-audio.dist config
cp config-video.dist config
nano config
./install-audio-player.sh 2>&1 | tee /install-audio.log
./install-video-player.sh 2>&1 | tee /install-video.log

=== Bei Videoplayer USB Mount installieren (s. unten) ===

=== Nextcloud install ===
./install-nextcloud-cmd.sh (bei Video Player install-nextcloud-cmd-buster.sh)
nano /home/pi/mh_prog/wss-install/nextcloud-sync.sh
-> Videoplayer => LOCAL=/media/usb_red/Nextcloud/
nano ~/.netrc
crontab -e

=== Power-Button install ===
./install-powerblock.sh
./install-mausberry.sh

=== Soundcard install ===
./install-iqaudio.sh
./install-hifiberry.sh

=== Soundkarte ermitteln (ggf. nicht bei IQAudio & Hifiberry -> HDMI-Screen entfernen vorher) ===
aplay -l

nano /usr/share/alsa/alsa.conf
- defaults.ctl.card CARD-Nr
- defaults.pcm.card CARD-Nr

=== gleichzeitiges Abspielen von Musik und Button Beep === (bei IQAuadio & Hifiberry, ggf. Wert schon ok)
nano /etc/asound.conf
speaker-test -c2

=== AudioServer config ===
alsamixer
nano /home/pi/mh_prog/AudioServer/config.json

=== USB-RFID-Reader === (erst USB-Dongle entfernen und reboot)
cat /dev/input/event0
nano /home/pi/mh_prog/AudioServer/config.json

=== STT === (erst USB-Dongle entfernen und reboot)
arecord --list-devices
nano /home/pi/mh_prog/AudioServer/config.json

=== .htaccess für wap in Nextcloud-Ordner kopieren === (wenn Sync abgeschlossen ist)
cp /home/pi/mh_prog/wss-install/.htaccess-wap /home/pi/Nextcloud/audio/website/wap/.htaccess

=== check start time ===
systemd-analyze blame

==============================

=== USB automount (Video) ===
blkid -o list -w /dev/null 
-> get UUID C470BE3C70BE34D0

NO (apt-get install -y ntfs-3g) -> ntfs schon installiert

nano /etc/fstab 
UUID=C470BE3C70BE34D0 /media/usb_red/ ntfs-3g utf8,uid=pi,gid=pi,noatime 0
reboot damit USB-Stick gemountet wird