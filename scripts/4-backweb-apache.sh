#!/bin/bash

# disable ssh password authentication
sed -i.org -e "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
sed -i.org -e "s/#PubkeyAuthentication/PubkeyAuthentication/g" /etc/ssh/sshd_config
sed -i.org -e "s/#RSAAuthentication/RSAAuthentication/g" /etc/ssh/sshd_config

# change timezone
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# install nginx
# rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
# yum -y install nginx
# chkconfig nginx on
# service nginx start

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
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT # https
iptables -A INPUT -p tcp -m tcp --dport 10050 -j ACCEPT # https
iptables -A INPUT -p tcp -m tcp --dport 10051 -j ACCEPT # https
iptables -P INPUT REJECT
iptables -P OUTPUT ACCEPT
service iptables save

# automatically start iptables
chkconfig iptables on

# install epel
yum -y install epel-release

# install mysql
# mysql-server
# sed -e 's/\[mysqld\]/\[mysqld\]\ndefault_character_set\=utf8/g' /etc/my.cnf
# chkconfig mysqld on
# service mysqld start
-
# install wordpress
yum -y install wordpress --enablerepo=epel
sed -i -e 's/Deny from All/Deny from All\n    Allow from All/g' /etc/httpd/conf.d/wordpress.conf


# setup mysql database
# mysql -e 'create database wordpress;' -uroot
# mysql -e 'GRANT ALL ON wordpress.* TO wordpress@localhost identified by "wordpress";' -uroot

# setup wordpress
sed -i -e 's/database_name_here/wordpress_db/g' /etc/wordpress/wp-config.php
sed -i -e 's/username_here/wordpress_user/g' /etc/wordpress/wp-config.php
sed -i -e 's/password_here/wordpress_pass/g' /etc/wordpress/wp-config.php

# set db's private ip address
# sed -i -e 's/localhost/10.90.65.131/g' /etc/wordpress/wp-config.php

# set httpd to startup
chkconfig httpd on
service httpd start

# End
echo "****************************************************************************" >> /etc/motd
echo "  Provisioning (backweb_apache.sh) was successful!!!" >> /etc/motd
echo "****************************************************************************" >> /etc/motd
history -c
