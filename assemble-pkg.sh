#! /bin/sh

mkdir /tmp/rappkg/

mkdir /tmp/rappkg/DEBIAN/
cp ./control /tmp/rappkg/DEBIAN/
cp ./postinst /tmp/rappkg/DEBIAN/

mkdir -p /tmp/rappkg/etc/apache2/sites-available/
cp ./rewrite-ssl.conf /tmp/rappkg/etc/apache2/sites-available/

mkdir /tmp/rappkg/etc/default/
cp ./raprec.defaults /tmp/rappkg/etc/default/raprec

mkdir /tmp/rappkg/etc/hostapd/
cp ./hostapd-rap.conf /tmp/rappkg/etc/hostapd/

mkdir -p /tmp/rappkg/lib/systemd/system/
cp ./raprec.service /tmp/rappkg/lib/systemd/system/

mkdir /tmp/rappkg/tmp/
cp ./dnsmasq.conf /tmp/rappkg/tmp/
cp ./roadapplepi.sql /tmp/rappkg/tmp/

mkdir -p /tmp/rappkg/var/www/html
cp ./html/* /tmp/rappkg/var/www/html/

make

mkdir -p /tmp/rappkg/usr/bin/
cp ./raprec /tmp/rappkg/usr/bin/
cp ./raprun /tmp/rappkg/usr/bin/
chmod +x /tmp/rappkg/usr/bin/raprec

dpkg-deb --build --root-owner-group /tmp/rappkg
