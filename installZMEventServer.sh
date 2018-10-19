#!/bin/bash
echo "Installing ZMEventServer dependancies"
set -x
apt-get update && apt-get install -y \
    libyaml-perl \
    make \
    libjson-perl \
    libcrypt-mysql-perl 

PERL_MM_USE_DEFAULT=1 perl -MCPAN -e "install Crypt::MySQL"
PERL_MM_USE_DEFAULT=1 perl -MCPAN -e "install Config::IniFiles"
PERL_MM_USE_DEFAULT=1 perl -MCPAN -e "install LWP::Protocol::https"
PERL_MM_USE_DEFAULT=1 perl -MCPAN -e "install Net::MQTT::Simple"
PERL_MM_USE_DEFAULT=1 perl -MCPAN -e "install Net::WebSocket::Server"
#
echo "Finished Installing ZMEventServer dependancies"
cd /usr/bin 
wget https://raw.githubusercontent.com/pliablepixels/zmeventserver/master/zmeventnotification.pl
chmod +x /usr/bin/zmeventnotification.pl
#
echo "Installation of ZMEvent Server"
