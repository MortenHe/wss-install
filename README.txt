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
cp config-audio.dist config (Achtung nicht config-audio) | cp config-video.dist config (Achtung nicht config-video)
nano config (PW setzen)
./install-audio-player.sh | ./install-video-player.sh

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

//RFID-USB-READER
cat /dev/input/event0

=== check start time ===
systemd-analyze blame

=== USB automount ===
blkid -o list -w /dev/null 
-> get UUID like E012519312517010 | B8EA48B6EA487324 | 78C20C88C20C4CB6

thonny /etc/fstab 
UUID=C470BE3C70BE34D0 /media/usb_red/ ntfs-3g utf8,uid=pi,gid=pi,noatime 0
reboot damit USB-Stick gemountet wird

wenn Audio nicht auf SD Karte
UUID=E012519312517010 /media/usb_audio/ ntfs-3g utf8,uid=pi,gid=pi,noatime 0
UUID=B8EA48B6EA487324 /media/usb_audio/ ntfs-3g utf8,uid=pi,gid=pi,noatime 0
UUID=78C20C88C20C4CB6 /media/usb_audio/ ntfs-3g utf8,uid=pi,gid=pi,noatime 0
reboot damit USB-Stick gemountet wird

=== Nextcloud GUI ===
Zubehör / Nextcloud Client
Konto Audio | Video
Alle Dateien sync
keine Bestätitung erfragen für 500MB / externe Speicher
/home/pi/Nextcloud | /media/usb_red/Nextcloud
Schlüsselbund -> leeres PW
Nextcloud Autostart aktivieren

=== Mausberry power button ===
out GPIO 23 (8. Pin von Seite SD-Karte aussen)
in GPIO 24 (9. Pin von Seite SD-Karte aussen)