#!/bin/sh -x

minimal_apt_get_args='-y --no-install-recommends'

SERVICE_PACKAGES="nano tar htop curl"
LIBS_PACKAGES="libxml2-dev libjansson-dev libncurses5-dev libgsm1-dev libspeex-dev libspeexdsp-dev libssl-dev libsqlite3-dev libedit-dev libodbc1 ca-certificates"
BUILD_PACKAGES="wget subversion build-essential uuid-dev unixodbc-dev pkg-config"
RUN_PACKAGES="openssl sqlite3 fail2ban iptables php-cli"

apt-get update -y
apt-get install $minimal_apt_get_args $SERVICE_PACKAGES $LIBS_PACKAGES $BUILD_PACKAGES

# asterisk-16.3.0.tar.gz
cd /tmp
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16.3.0.tar.gz
mkdir asterisk
tar -xzvf asterisk-16.3.0.tar.gz -C asterisk/ --strip-components=1

wget http://raw.githubusercontent.com/asterisk/third-party/master/pjproject/2.8/pjproject-2.8.tar.bz2 --no-check-certificate

cd /tmp/asterisk
sh contrib/scripts/get_mp3_source.sh
cp /tmp/menuselect.makeopts /tmp/asterisk/menuselect.makeopts
./configure CFLAGS='-g -O2 -mtune=native' --libdir=/usr/lib/x86_64-linux-gnu --with-pjproject-bundled PJPROJECT_URL=http://raw.githubusercontent.com/asterisk/third-party/master/pjproject/2.8/pjproject-2.8.tar.bz2 
make && make install && make samples

# add g729
wget http://asterisk.hosting.lv/bin/codec_g723-ast160-gcc4-glibc-x86_64-pentium4.so -O codec_g729.so
mv codec_g729.so /usr/lib/x86_64-linux-gnu/asterisk/modules/

touch /var/log/auth.log /var/log/asterisk/messages /var/log/asterisk/security

# install run packages
apt-get install $minimal_apt_get_args $RUN_PACKAGES

# fail2ban configure
rm /etc/fail2ban/filter.d/asterisk.conf
cp /tmp/asterisk*.conf /etc/fail2ban/filter.d/
cat /tmp/jail.conf >> /etc/fail2ban/jail.conf

# clean
apt-get remove --purge -y $BUILD_PACKAGES
apt-get -y autoremove
apt-get install $minimal_apt_get_args $LIBS_PACKAGES
apt-get -y clean
rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/*