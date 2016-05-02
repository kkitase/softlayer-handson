#!/bin/bash

# Update latest patch
yum update -y

# Add EPEL Repo
wget http://ftp.riken.jp/Linux/fedora/epel/RPM-GPG-KEY-EPEL-6
rpm --import RPM-GPG-KEY-EPEL-6
rm -f RPM-GPG-KEY-EPEL-6
echo '[epel]' >> /etc/yum.repos.d/epel.repo
echo 'name=EPEL RPM Repository for Red Hat Enterprise Linux' >> /etc/yum.repos.d/epel.repo
echo 'baseurl=http://ftp.riken.jp/Linux/fedora/epel/6/$basearch/' >> /etc/yum.repos.d/epel.repo
echo 'gpgcheck=1' >> /etc/yum.repos.d/epel.repo
echo 'enabled=0' >> /etc/yum.repos.d/epel.repo

# Add MongoDB Repo
echo '[mongodb-org-3.0]' >> /etc/yum.repos.d/mongodb-org-3.0.repo
echo 'name=MongoDB Repository' >> /etc/yum.repos.d/mongodb-org-3.0.repo
echo 'baseurl=http://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.0/x86_64/' >> /etc/yum.repos.d/mongodb-org-3.0.repo
echo 'gpgcheck=0' >> /etc/yum.repos.d/mongodb-org-3.0.repo
echo 'enabled=1' >> /etc/yum.repos.d/mongodb-org-3.0.repo

# Disable tunnelled clear text passwords
sed -i.org -e "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
service sshd restart

# Change to Japanese locale
yum groupinstall "Japanese Support" -y 
sed -i.org -e "s/en_US.UTF-8/ja_JP.UTF-8/g" /etc/sysconfig/i18n

# Change to JST time zone
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# Install basic tools
# yum install iperf --enablerepo=epel -y
# yum install -y git-all.noarch httpd cifs-utils php php-mysql php-mbstring
# chkconfig httpd on
# service httpd start

# Configure Linux Firewall
# --- CAUTION --- Change to deny access from public address
# 1883: Mosquitto
# 5001: iperf
# 1880: Node-RED
# 27017: MongoDB
iptables -A INPUT -s 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 1883 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --sport 1883 -j ACCEPT
iptables -A INPUT -m state --state NEW -m udp -p udp --dport 1883 -j ACCEPT
iptables -A INPUT -m state --state NEW -m udp -p udp --sport 1883 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 1880 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --sport 1880 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 27017 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --sport 27017 -j ACCEPT
iptables -A INPUT -s 0.0.0.0/0 -d 0.0.0.0/0 -p all -j REJECT
service iptables save

# Install MongoDB
yum install -y mongodb-org
chkconfig mongod on
# service mongod start

# Install broker
cd /etc/yum.repos.d
wget http://download.opensuse.org/repositories/home:/oojah:/mqtt/CentOS_CentOS-6/home:oojah:mqtt.repo
yum install mosquitto -y
chkconfig mosquitto on
# /usr/sbin/mosquitto &

# Install client
yum install mosquitto-clients -y

# Install node.js and npm
yum install epel-release -y
yum install nodejs npm --enablerepo=epel -y

# Install node-red, mongo node
npm install -g node-red
npm install -g node-red-node-mongodb
npm install -g node-red-contrib-mongodb2
# node-red &

# End
echo "****************************************************************************" >> /etc/motd
echo "  Provisioning was successful" >> /etc/motd
echo "  1) Start mosquitto: /usr/sbin/mosquitto & and" >> /etc/motd 
echo "     Subscribe and send msg: mosquitto_pub -d -t hello -m Hello world" >> /etc/motd
echo "  2) Comment out bindIp in /etc/mongod.conf and" >> /etc/motd
echo "     restart mongod: service mongod start" >> /etc/motd
echo "  3) Start node-red: node-red and access http://<IP>:1880" >> /etc/motd
echo "****************************************************************************" >> /etc/motd
history -c
