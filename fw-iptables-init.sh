#!/bin/sh
IPTABLES=/sbin/iptables

# IP-Forwarding im Kernel einschalten
/bin/echo 1 > /proc/sys/net/ipv4/ip_forward

#
# Firewallregeln loeschen
#
$IPTABLES -F
$IPTABLES -F -t nat
$IPTABLES -X
$IPTABLES -X -t nat

#
# Standardregel DROP
#
$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT DROP

# Chains
$IPTABLES -N http_in
$IPTABLES -A http_in -j ACCEPT
$IPTABLES -N http_out
$IPTABLES -A http_out -j ACCEPT
$IPTABLES -N teamspeak_out
$IPTABLES -A teamspeak_out -j ACCEPT
$IPTABLES -N teamspeak_in
$IPTABLES -A teamspeak_in -j ACCEPT

#
# Natd
#
$IPTABLES -t nat -A POSTROUTING -o eth0 -s 10.4.0.0/8 -j MASQUERADE

#
# Transparent Proxy
#
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 3128

#
# Allow localhost
#
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A OUTPUT -o lo -j ACCEPT

#
# Ausgehende mit Tracking
#

$IPTABLES -A OUTPUT -o eth0 -m owner --uid-owner 13 -j http_out
$IPTABLES -A OUTPUT -o eth0 -m owner --uid-owner 113 -j teamspeak_out
$IPTABLES -A OUTPUT -o eth0 -m owner --uid-owner 1004 -j teamspeak_out

#
# Ausgehende immer erlauben
#
$IPTABLES -A OUTPUT -o eth0 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -o eth1 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -o tap0 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

#
# Antworten mit Tracking
#

# Squid
$IPTABLES -A INPUT -i eth0 -m state --state NEW,ESTABLISHED,RELATED --protocol tcp -d 10.4.0.20 --dport 3128 -j http_in
$IPTABLES -A INPUT -i eth1 -m state --state NEW,ESTABLISHED,RELATED --protocol tcp -d 10.4.0.20 --dport 3128 -j http_in
# Teamspeak 2
$IPTABLES -A INPUT -i eth0 -m state --state NEW,ESTABLISHED,RELATED --protocol udp -d 77.244.108.198 --dport 8767 -j teamspeak_in
$IPTABLES -A INPUT -i eth0 -m state --state NEW,ESTABLISHED,RELATED --protocol udp -d 77.244.108.198 --dport 8768 -j teamspeak_in
$IPTABLES -A INPUT -i eth0 -m state --state NEW,ESTABLISHED,RELATED --protocol udp -d 77.244.108.198 --dport 8769 -j teamspeak_in
$IPTABLES -A INPUT -i eth0 -m state --state NEW,ESTABLISHED,RELATED --protocol udp -d 77.244.108.198 --dport 8770 -j teamspeak_in
$IPTABLES -A INPUT -i eth0 -m state --state NEW,ESTABLISHED,RELATED --protocol udp -d 77.244.108.198 --dport 8771 -j teamspeak_in
$IPTABLES -A INPUT -i eth0 -m state --state NEW,ESTABLISHED,RELATED --protocol udp -d 77.244.108.198 --dport 8772 -j teamspeak_in
$IPTABLES -A INPUT -i eth0 -m state --state NEW,ESTABLISHED,RELATED --protocol udp -d 77.244.108.198 --dport 8773 -j teamspeak_in
$IPTABLES -A INPUT -i eth0 -m state --state NEW,ESTABLISHED,RELATED --protocol udp -d 77.244.108.198 --dport 8774 -j teamspeak_in
$IPTABLES -A INPUT -i eth0 -m state --state NEW,ESTABLISHED,RELATED --protocol udp -d 77.244.108.198 --dport 8775 -j teamspeak_in
# Teamspeak 3
$IPTABLES -A INPUT -i eth0 -m state --state NEW,ESTABLISHED,RELATED --protocol udp -d 77.244.108.198 --dport 9987 -j teamspeak_in

#
# Antworten erlauben
#
$IPTABLES -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state ESTABLISHED,RELATED -j ACCEPT

#
# Ports freigeben
#
# Ping
$IPTABLES -A INPUT -i eth0 -p icmp --icmp-type 8 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -p icmp --icmp-type 8 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -p icmp --icmp-type 8 -j ACCEPT
$IPTABLES -A INPUT -i eth0 -p icmp --icmp-type 11 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -p icmp --icmp-type 11 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -p icmp --icmp-type 11 -j ACCEPT
# SSH
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp --dport 22 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp --dport 22 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol tcp --dport 22 -j ACCEPT
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp --dport 1022 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp --dport 1022 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol tcp --dport 1022 -j ACCEPT
# OpenVPN
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 563 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 563 -j ACCEPT
# Bind
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 53 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp -d 10.4.0.20 --dport 53 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 953 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 53 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp -d 10.4.0.20 --dport 53 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 953 -j ACCEPT
# Git
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp -d 77.244.108.198 --dport 9418 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 9418 -j ACCEPT
# snmpd
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp -d 10.4.0.20 --dport 161 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp -d 10.4.0.20 --dport 161 -j ACCEPT
# apache
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp -d 77.244.108.206 --dport 80 -j ACCEPT
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp -d 77.244.108.198 --dport 80 -j ACCEPT
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp -d 77.244.108.206 --dport 443 -j ACCEPT
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp -d 77.244.108.198 --dport 443 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 443 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp -d 10.4.0.23 --dport 443 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 80 -j ACCEPT
# squid
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp -d 77.244.108.206 --dport 3128 -j ACCEPT
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp -d 77.244.108.198 --dport 3128 -j ACCEPT
# openfire / xmpp
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp -d 77.244.108.206 --dport 5222 -j ACCEPT
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp -d 77.244.108.198 --dport 5222 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp -d 10.4.0.23 --dport 5222 -j ACCEPT
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp -d 77.244.108.206 --dport 5269 -j ACCEPT
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp -d 77.244.108.198 --dport 5269 -j ACCEPT
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp -d 10.4.0.23 --dport 5269 -j ACCEPT
# cassandra
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol tcp -d 10.4.0.20 --dport 9160 -j ACCEPT
# amanda-client
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol tcp --dport 11000:11040 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp --dport 10080 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol tcp --dport 10080 -j ACCEPT
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol tcp --dport 11000:11040 -j ACCEPT

#
# Portforwarding
#
# Squid
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.206 --dport 443 -j DNAT --to-destination 10.4.0.20:3128

# OpenFire
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.198 --dport 5222 -j DNAT --to-destination 10.4.0.23:5222
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.206 --dport 5222 -j DNAT --to-destination 10.4.0.23:5222
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.198 --dport 5269 -j DNAT --to-destination 10.4.0.23:5269
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.206 --dport 5269 -j DNAT --to-destination 10.4.0.23:5269

# SSH
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.198 --dport 10420 -j DNAT --to-destination 10.4.0.20:22
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.198 --dport 10421 -j DNAT --to-destination 10.4.0.21:22
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.198 --dport 10422 -j DNAT --to-destination 10.4.0.22:22
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.198 --dport 10423 -j DNAT --to-destination 10.4.0.23:22
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.198 --dport 10424 -j DNAT --to-destination 10.4.0.24:22
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.198 --dport 10425 -j DNAT --to-destination 10.4.0.25:22
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.198 --dport 10426 -j DNAT --to-destination 10.4.0.26:22
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.198 --dport 10427 -j DNAT --to-destination 10.4.0.27:22
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.198 --dport 10428 -j DNAT --to-destination 10.4.0.28:22
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.198 --dport 10429 -j DNAT --to-destination 10.4.0.29:22
# OpenVPN
$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.198 --dport 563 -j DNAT --to-destination 10.4.0.20:563
# FTP
#$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.198 --dport 21 -j DNAT --to-destination 10.4.0.22:21
#$IPTABLES -t nat -A PREROUTING -i eth0 -p tcp -d 77.244.108.198 --dport 63000:63999 -j DNAT --to-destination 10.4.0.22

#
# Forward
#
$IPTABLES -A FORWARD -i eth0 -o eth1 -j ACCEPT
$IPTABLES -A FORWARD -o eth0 -i eth1 -j ACCEPT
$IPTABLES -A FORWARD -i eth1 -o tap0 -j ACCEPT
$IPTABLES -A FORWARD -o eth1 -i tap0 -j ACCEPT
$IPTABLES -A FORWARD -i tap0 -o eth0 -j ACCEPT
$IPTABLES -A FORWARD -o tap0 -i eth0 -j ACCEPT

#
# Ports explizit sperren
#
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 67 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp --dport 67 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp --dport 67 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 68 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp --dport 68 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp --dport 68 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 111 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp --dport 111 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp --dport 111 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 137 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp --dport 137 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp --dport 137 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 138 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp --dport 138 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp --dport 138 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol tcp --dport 139 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol tcp --dport 139 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol tcp --dport 139 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 6155 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp --dport 6155 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp --dport 6155 -j DROP
$IPTABLES -A INPUT -i eth0 -m state --state NEW --protocol udp --dport 6780 -j DROP
$IPTABLES -A INPUT -i eth1 -m state --state NEW --protocol udp --dport 6780 -j DROP
$IPTABLES -A INPUT -i tap0 -m state --state NEW --protocol udp --dport 6780 -j DROP

#
# Rest loggen
#
$IPTABLES -A INPUT -j LOG --log-prefix="IPTABLES-INPUT: "
$IPTABLES -A OUTPUT -j LOG --log-prefix="IPTABLES-OUTPUT: "
$IPTABLES -A FORWARD -j LOG --log-prefix="IPTABLES-FORWARD: "
