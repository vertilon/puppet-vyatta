#!/bin/bash 
cd /tmp 
apt-get update
yes | apt-get -y install openvpn git
wget http://swupdate.openvpn.org/community/releases/easy-rsa-2.2.0_master.tar.gz
tar zxf easy-rsa-2.2.0_master.tar.gz 
mkdir /etc/openvpn/easy-rsa/
cd easy-rsa-2.2.0_master/
./configure && make && make install 
cp -r /usr/local/share/easy-rsa/* /etc/openvpn/easy-rsa/
cd /etc/openvpn/easy-rsa/
source vars
./clean-all

./pkitool --initca
./pkitool --server server
./build-dh
cd /etc/openvpn/easy-rsa/keys/
cp server.crt server.key ca.crt dh1024.pem /etc/openvpn/
cd /etc/openvpn/easy-rsa/
source vars
export KEY_NAME=agent
./pkitool agent
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
cd /etc/openvpn/
gzip -d /etc/openvpn/server.conf.gz
echo "push \"route 10.8.0.1 255.255.255.0\"" >> /etc/openvpn/server.conf
service openvpn start