=== Audio / Video Player ===
Raspberry Pi Imager -> Raspian Lite

SSH, PW und WLAN per Pi Imager setzen

(Datei "ssh" in SD-boot Verzeichnis)
(Datei "wpa_supplicant.conf" in SD-boot Verzeichnis und anpassen)

Über Router http://192.168.0.1/ IP-Adresse des Pi ermitteln

ssh pi@192.168.0.92
(pi / raspberry (z = y) falls nicht schon eigenes PW über Pi Imager gesetzt)

sudo -s
raspi-config

1
(S3 change user pi password : XXX)
S6 Don't wait for network (No)

5
(L1 de_DE utf-8)
(L2 Europe -> Berlin)
(L3 Generic 105 - Other - German - German - Default - Default)

=== WSS install ===
apt-get install -y git

mkdir mh_prog
cd mh_prog

git clone https://github.com/MortenHe/wss-install
cd wss-install
cp config-audio.dist config (Achtung nicht config-audio)
cp config-video.dist config (Achtung nicht config-video)
nano config (PW setzen)
./install-audio-player.sh 2>&1 | tee /install-audio.log
./install-video-player.sh 2>&1 | tee /install-video.log

=== Nextcloud install ===
./install-nextcloud-cmd.sh
nano /home/pi/mh_prog/wss-install/nextcloud-sync.sh (-s ggf. wegmachen)
nano ~/.netrc
crontab -e

=== Power-Button install ===
./install-powerblock.sh
./install-mausberry.sh

=== Soundcard install ===
./install-iqaudio.sh
./install-hifiberry.sh

=== Soundkarte ermitteln ===
aplay -l

nano /usr/share/alsa/alsa.conf
- defaults.ctl.card CARD-Nr
- defaults.pcm.card CARD-Nr
speaker-test -c2

=== AudioServer config ===
alsamixer
nano /home/pi/mh_prog/AudioServer/config.json

//USB-RFID-Reader
cat /dev/input/event0
nano /home/pi/mh_prog/AudioServer/config.json

=== check start time ===
systemd-analyze blame

==============================

=== USB automount (Video) ===
blkid -o list -w /dev/null 
-> get UUID like E012519312517010 | B8EA48B6EA487324 | 78C20C88C20C4CB6

thonny /etc/fstab 
UUID=C470BE3C70BE34D0 /media/usb_red/ ntfs-3g utf8,uid=pi,gid=pi,noatime 0
reboot damit USB-Stick gemountet wird