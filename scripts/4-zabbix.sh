#!/bin/bash

# disable ssh password authentication
sed -i.org -e "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
sed -i.org -e "s/#PubkeyAuthentication/PubkeyAuthentication/g" /etc/ssh/sshd_config
sed -i.org -e "s/#RSAAuthentication/RSAAuthentication/g" /etc/ssh/sshd_config

# change timezone
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# install apache http server
yum -y install httpd
service httpd on
chkconfig httpd on

# install mysql server
yum -y install mysql-server
sed -e 's/\[mysqld\]/\[mysqld\]\ndefault_character_set\=utf8/g' /etc/my.cnf
echo "[mysql]" >> /etc/my.cnf
echo "default_character_set=utf8" >> /etc/my.cnf
chkconfig mysqld on
service mysqld start

# install zabbix repository
rpm -ivh http://repo.zabbix.com/zabbix/2.4/rhel/6/x86_64/zabbix-release-2.4-1.el6.noarch.rpm

# install zabbix agent
yum -y install zabbix-agent zabbix-get

# install zabbix server
yum -y install zabbix-server-mysql zabbix-web-mysql
cd /usr/share/doc/zabbix-server-mysql-2.4.7/create
mysql -e 'create database zabbix;' -uroot
mysql -uroot zabbix < schema.sql
mysql -uroot zabbix < images.sql
mysql -uroot zabbix < data.sql
mysql -e 'GRANT ALL ON zabbix.* TO zabbix@localhost identified by "zabbix";' -uroot

cat << EOF >> /etc/zabbix/zabbix_server.conf
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=zabbix
EOF

sed -i -e 's/# php_value date.timezone Europe\/Riga/php_value date.timezone Asia\/Tokyo/g' /etc/httpd/conf.d/zabbix.conf

service httpd restart
service zabbix-server start
chkconfig zabbix-server on

# iptables setting
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT # ssh
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT # http
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT # https
iptables -A INPUT -p tcp -m tcp --dport 10050 -j ACCEPT # zabbix
iptables -A INPUT -p tcp -m tcp --dport 10051 -j ACCEPT # zabbix
iptables -P INPUT REJECT
iptables -P OUTPUT ACCEPT
service iptables save

# automatically start iptables
chkconfig iptables on

# End
echo "****************************************************************************" >> /etc/motd
echo "  Provisioning (zabbix.sh) was successful!!!" >> /etc/motd
echo "****************************************************************************" >> /etc/motd
history -c
