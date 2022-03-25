#!/bin/bash
softwareVersion=$(git describe --long)

echo -e "\e[1;4;246mRoadApplePi Setup $softwareVersion\e[0m
Welcome to RoadApplePi setup. RoadApplePi is \"Black Box\" software that
can be retrofitted into any car with an OBD port. This software is meant
to be installed on a Raspberry Pi running unmodified Raspbian Stretch,
but it may work on other OSs or along side other programs and modifications.
Use with anything other then out-of-the-box Vanilla Raspbain Stretch is not
supported.

This script will download, compile, and install the necessary dependencies
before finishing installing RoadApplePi itself. Depending on your model of
Raspberry Pi, this may take several hours.
"

#Prompt user if they want to continue
read -p "Would you like to continue? (y/N) " answer
if [ "$answer" == "n" ] || [ "$answer" == "N" ] || [ "$answer" == "" ]
then
	echo "Setup aborted"
	exit
fi

#################
# Update System #
#################
echo -e "\e[1;4;93mStep 1. Updating system\e[0m"
sudo apt update
sudo apt upgrade -y

###########################################
# Install pre-built dependencies from Apt #
###########################################
echo -e "\e[1;4;93mStep 2. Install pre-built dependencies from Apt\e[0m"
sudo apt install -y dnsmasq hostapd libbluetooth-dev apache2 \
    php7.4 php7.4-mysql php7.4-bcmath \
    mariadb-server libmariadb-dev libmariadb-dev-compat \
    uvcdynctrl
sudo systemctl disable hostapd dnsmasq
sudo apt install -y ffmpeg

################
# Build FFMpeg #
################
#echo -e "\e[1;4;93mStep 3. Build ffmpeg (this may take a while)\e[0m"
#ffmpegLocation=$(which ffmpeg)
#if [ $? != 0 ]
#then
#	wget https://www.ffmpeg.org/releases/ffmpeg-3.4.2.tar.gz
#	tar -xvf ffmpeg-3.4.2.tar.gz
#	cd ffmpeg-3.4.2
#	echo "./configure --enable-gpl --enable-nonfree --enable-mmal --enable-omx --enable-omx-rpi"
#	./configure --enable-gpl --enable-nonfree --enable-mmal --enable-omx --enable-omx-rpi
#	make -j$(nproc)
#	sudo make install
#   cd ..
#else
#	echo "FFMpeg already found at $ffmpegLocation! Using installed version."
#fi

#######################
# Install RoadApplePi #
#######################
echo -e "\e[1;4;93mStep 4. Building and installing RoadApplePi\e[0m"
make
sudo make install

sudo cp -r html /var/www/
sudo rm /var/www/html/index.html
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 0755 /var/www/html
sudo install -o root -g root -m 0755 raprec.service /lib/systemd/system
[ -f /etc/default/raprec ] || sudo install -o root -g root -m 0644 -T raprec.defaults /etc/default/raprec
sudo systemctl daemon-reload
sudo systemctl enable raprec
sudo cp hostapd-rap.conf /etc/hostapd
sudo cp dnsmasq.conf /etc
sudo mkdir /var/www/html/vids
sudo chown -R www-data:www-data /var/www/html

#Enable raspi camera module
raspi-config nonint do_camera 1

# Enable SSL and HTTP => HTTPS redirect.
sudo install -o root -g root -m 0644 rewrite-ssl.conf /etc/apache2/sites-available
sudo a2enmod ssl
sudo a2ensite default-ssl
sudo a2enmod rewrite
sudo a2ensite rewrite-ssl
sudo a2dissite 000-default

installDate=$(date)
cp roadapplepi.sql roadapplepi-configd.sql
echo "INSERT INTO env (name, value) VALUES (\"rapVersion\", \"$softwareVersion\"), (\"installDate\", \"$installDate\");" >> roadapplepi-configd.sql
sudo mysql < roadapplepi-configd.sql

echo "Done! Please reboot your Raspberry Pi now"
