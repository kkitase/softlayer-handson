#!/bin/bash

# disable ssh password authentication
sed -i.org -e "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
sed -i.org -e "s/#PubkeyAuthentication/PubkeyAuthentication/g" /etc/ssh/sshd_config
sed -i.org -e "s/#RSAAuthentication/RSAAuthentication/g" /etc/ssh/sshd_config

# change timezone
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# install mysql
yum -y install mysql-server
sed -i -e 's/\[mysqld\]/\[mysqld\]\ndefault_character_set\=utf8/g' /etc/my.cnf
sed -i -e 's/\[mysqld\]/\[mysqld\]\ndefault_character_set\=utf8/g' /etc/my.cnf
echo "[mysql]" >> /etc/my.cnf
echo "default_character_set=utf8" >> /etc/my.cnf
chkconfig mysqld on
service mysqld start

# install zabbix repository
rpm -ivh http://repo.zabbix.com/zabbix/2.4/rhel/6/x86_64/zabbix-release-2.4-1.el6.noarch.rpm

# install zabbix agent
yum -y install zabbix-agent zabbix-get
chkconfig zabbix-agent on

# drop request from public network
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT

iptables -A INPUT -s 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT # ssh
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT # http
iptables -A INPUT -p tcp -m tcp --dport 3306 -j ACCEPT # mysql
iptables -A INPUT -p tcp -m tcp --dport 10050 -j ACCEPT # zabbix
iptables -A INPUT -p tcp -m tcp --dport 10051 -j ACCEPT # zabbix
iptables -P INPUT REJECT
iptables -P OUTPUT ACCEPT
service iptables save

# automatically start iptables
chkconfig iptables on

# create local db
mysql -e 'create database wordpress_db;' -uroot
mysql -e 'grant all on wordpress_db.* to wordpress_user@"%" identified by "wordpress_pass";' -uroot

# End
echo "****************************************************************************" >> /etc/motd
echo "  Provisioning (db.sh) was successful!!!" >> /etc/motd
echo "****************************************************************************" >> /etc/motd
history -c
