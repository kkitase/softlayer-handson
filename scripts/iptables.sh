#!/bin/bash

# initialize
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD

# accept connection (from / to) localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT

########## FIREWALL RULE START ##########

# accept connection to some server
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT # ssh
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT # http
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT # https
iptables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT # smtp
iptables -A INPUT -p tcp -m tcp --dport 465 -j ACCEPT # smtps
iptables -A INPUT -p tcp -m tcp --dport 587 -j ACCEPT # submission
iptables -A INPUT -p tcp -m tcp --dport 110 -j ACCEPT # pop3
iptables -A INPUT -p tcp -m tcp --dport 143 -j ACCEPT # imap
iptables -A INPUT -p tcp -m tcp --dport 993 -j ACCEPT # imaps
iptables -A INPUT -p tcp -m tcp --dport 995 -j ACCEPT # pop3s

########## FIREWALL RULE END ##########

# block conection to other ports
iptables -P INPUT DROP

# accept outbound connection
iptables -P OUTPUT ACCEPT



# accept responce from external host
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

/etc/init.d/iptables save
chkconfig iptables on
