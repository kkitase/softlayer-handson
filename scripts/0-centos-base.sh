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

# Disable tunnelled clear text passwords
# sed -i.org -e "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
# service sshd restart

# Change to Japanese locale
yum groupinstall "Japanese Support" -y 
sed -i.org -e "s/en_US.UTF-8/ja_JP.UTF-8/g" /etc/sysconfig/i18n

# Change to JST time zone
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# Install basic tools
# yum install -y emacs.x86_64 git-all.noarch httpd cifs-utils php php-mysql php-mbstring
# chkconfig httpd on
# service httpd start
#yum install iperf --enablerepo=epel -y

# Configure Linux Firewall
# --- CAUTION --- Change to deny access from public address
iptables -A INPUT -s 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
#iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 5001 -j ACCEPT
iptables -A INPUT -s 0.0.0.0/0 -d 0.0.0.0/0 -p all -j REJECT
service iptables save

# End
echo "****************************************************************************" >> /etc/motd
echo "  Provisioning (centos-base.sh) was successful!!!" >> /etc/motd
echo "****************************************************************************" >> /etc/motd
history -c
