#!/bin/bash

# disable ssh password authentication
sed -i.org -e "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
sed -i.org -e "s/#PubkeyAuthentication/PubkeyAuthentication/g" /etc/ssh/sshd_config
sed -i.org -e "s/#RSAAuthentication/RSAAuthentication/g" /etc/ssh/sshd_config

service sshd restart

# change timezone
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

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
iptables -A INPUT -p tcp -m tcp --dport 9000 -j ACCEPT # https
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
chkconfig httpd off
service httpd stop

# install nginx
rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
yum -y install nginx
chkconfig nginx on
service nginx start

# install php-fpm for wordpress on nginx
yum -y install php-fpm

# setting nginx as a http server
sed -i.bak -e 's/= apache$/= nginx/g' /etc/php-fpm.d/www.conf
sed -i -e 's/pm = dynamic/pm = static/g' /etc/php-fpm.d/www.conf
sed -i -e 's/;pm.max_requests/pm.max_requests/g' /etc/php-fpm.d/www.conf
service php-fpm start
chkconfig php-fpm on

# setting wordpress for nginx
chown -R root:nginx /etc/wordpress

sed -i.bak -e '1,18s|location / {||' /etc/nginx/conf.d/default.conf
sed -i -e '1,18s/}//g' /etc/nginx/conf.d/default.conf
sed -i -e '1,18s|/usr/share/nginx/html|/usr/share/wordpress|' /etc/nginx/conf.d/default.conf
sed -i -e '1,18s/index.html index.htm/index.php index.html index.htm/g' /etc/nginx/conf.d/default.conf

sed -i -e '11i \\' /etc/nginx/conf.d/default.conf
sed -i -e '12i location ~ \.php$ {' /etc/nginx/conf.d/default.conf
sed -i -e '13i        fastcgi_pass            127.0.0.1:9000;' /etc/nginx/conf.d/default.conf
sed -i -e '14i        fastcgi_index           index.php;' /etc/nginx/conf.d/default.conf
sed -i -e '15i        fastcgi_param           SCRIPT_FILENAME  $document_root$fastcgi_script_name;' /etc/nginx/conf.d/default.conf
sed -i -e '16i        fastcgi_pass_header     "X-Accel-Expires";' /etc/nginx/conf.d/default.conf
sed -i -e '17i        fastcgi_pass_header     "X-Accel-Redirect";' /etc/nginx/conf.d/default.conf
sed -i -e '18i        include                 fastcgi_params;' /etc/nginx/conf.d/default.conf
sed -i -e '19i     }' /etc/nginx/conf.d/default.conf

sed -i -e '21i try_files $uri $uri/ /index.php?q=$uri&$args;' /etc/nginx/conf.d/default.conf

# fix permissions
chown -R nginx:ftp /usr/share/wordpress/wp-content/plugins/
chown -R nginx:ftp /usr/share/wordpress/wp-content/themes/
chown -R nginx:ftp /usr/share/wordpress/wp-content/upgrade/
chown -R nginx:ftp /usr/share/wordpress/wp-content/uploads/

# install cache purge plugin
cd /usr/share/wordpress/wp-content/plugins/
wget https://downloads.wordpress.org/plugin/nginx-champuru.3.1.1.zip
unzip nginx-champuru.3.1.1.zip

# reload nginx config
service nginx reload

# setup lsyncd to sync cached contents between reverse proxy and cache node
yum -y install rssh lsyncd
echo "/usr/bin/rssh" >> /etc/shells
chsh -s /usr/bin/rssh nginx
gpasswd -a nginx rsshusers

sed -i.bak -e 's/#allowscp/allowscp/' /etc/rssh.conf
sed -i -e 's/#allowsftp/allowsftp/' /etc/rssh.conf
sed -i -e 's/#allowrsync/allowrsync/' /etc/rssh.conf

# End
echo "****************************************************************************" >> /etc/motd
echo "  Provisioning (backweb_nginx.sh) was successful!!!" >> /etc/motd
echo "****************************************************************************" >> /etc/motd
history -c
