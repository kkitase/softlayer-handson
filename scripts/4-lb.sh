#!/bin/bash

# disable ssh password authentication
sed -i.org -e "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
sed -i.org -e "s/#PubkeyAuthentication/PubkeyAuthentication/g" /etc/ssh/sshd_config
sed -i.org -e "s/#RSAAuthentication/RSAAuthentication/g" /etc/ssh/sshd_config

# change timezone
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# install nginx
rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
yum -y install nginx
chkconfig nginx on
service nginx start

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

# setup lsyncd to sync cached contents between reverse proxy and cache node
yum -y install epel-release
yum -y install rssh lsyncd
echo "/usr/bin/rssh" >> /etc/shells
chsh -s /usr/bin/rssh nginx
gpasswd -a nginx rsshusers

sed -i.bak -e 's/#allowscp/allowscp/' /etc/rssh.conf
sed -i -e 's/#allowsftp/allowsftp/' /etc/rssh.conf
sed -i -e 's/#allowrsync/allowrsync/' /etc/rssh.conf

# End
echo "****************************************************************************" >> /etc/motd
echo "  Provisioning (frontweb.sh) was successful!!!" >> /etc/motd
echo "****************************************************************************" >> /etc/motd
history -c
